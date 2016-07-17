part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable,
                                    Validatable
{
  /** Events emitted by the browser that we'd like to handle
   *  if you prefer to not listen to them all for your component,
   *  simply list the ones you'd like to listen to, ommiting all the others.
   *
   *  native_events_list is a variable defined in native_events_list.dart
   *  and it simply contains a List of all events Dart is capable of catching.
   *  If you'd like to listen to all of those native events, uncomment it and assign
   *  native_events to it, however not that it might affect performance.
   *
   *  If you want to catch events from descendants of the #dom_element, define events as
   *  "self.part_name" where part_name is identical to the value of the data-component-part
   *  html attribute of the descendant element.
   */
  List native_events = []; // native_events_list;

  /// a DOM element associated with this component
  HtmlElement _dom_element;

  /// ... and you can add more, for example [... ButtonBehaviors, LinkBehaviors] 
  List behaviors  = [BaseComponentBehaviors];
  /// instantiated behavior objects, don't touch it
  List _behaviors = [];

  /// Contains an element which will later be cloned and assigned to #dom_element
  /// if needed. Obviously, unless a real element from DOM isn't assigned.
  HtmlElement template;

  /** This is not to be updated manually. Validations for descenndants are defined along
    * all other validations in #validations Map, but dot (.) is used to separate roles of
    * descendants and property names. For example:
    *
    *   Map validations = {
    *     'form.input.text' => ...
    *   }
    *
    * would define a validation on the .text property of a component which has an "input" role,
    * which is also a child of an element with role "form", which, in turn, is a child of
    * the current component.
    */
  Map descendant_validations = {};

  /** This one is importany if you intrend to separate your app
    * into many parts (files). In that case, you'll need to declare a library.
    * Component then will look for its children in 'nest_ui' library as well as
    * app_library. Due to how Dart works, it's impossible to lookup for class names
    * without knowing which library do they belong. Thus, it's either '' (top level)
    * or your app_library name.
    */
  static String app_library = '';

  final Map attribute_callbacks = {
    'default' : (attr_name, self) => self.prvt_updatePropertyOnNode(attr_name)
  };

  /** Dom element is what it is: a DOM element in our HTML page, which is associated
   *  with the current component and to which callacks are attached (the natives ones).
   *  We need a custom setter to start listening to the native events that wi list in
   *  the #native_events property.
   */
  get dom_element => _dom_element;
  set dom_element(HtmlElement el) {
    _dom_element = el;
    if(el != null) {
      _assignRolesFromDomElement();
      _listenToNativeEvents();
    }
  }
  
  Component() {
    _separateDescendantValidations();
    _createBehaviors();
    _initTemplate();
  }

  /** Invokes behaviors which are defined in separate Behavior objects. Those objects are instantiated
   *  when the constructor is called. If you want to define custom Behaviors, simply create
   *  a MyBehaviors class and add into the #behaviors list.
   */
  behave(behavior) {
    _behaviors.forEach((b) {
      if(methods_of(b).contains(behavior)) {
        var im = reflect(b);
        im.invoke(new Symbol(behavior), []);
        return;
      }
    });
  }

  /** Very important! This is why the library is called nest_ui. Components are nested.
   *  This method goes through the #dom_element descendants looking for elements which
   *  have data-component-class attribute. If found, a new Component is created with the class
   *  specified in this attribute. Obviously, you should define such a class beforehand and
   *  inherit from Component.
  */
  initChildComponents({ recursive: true }) {
    var elements = _findChildComponentDomElements(this.dom_element);
    elements.forEach((el) {
      [Component.app_library, 'nest_ui'].forEach((l) {
        var component = new_instance_of(el.getAttribute('data-component-class'), [], l);
        if(component != null) {
          component.addObservingSubscriber(this);
          component.dom_element = el;
          this.addChild(component);
          component.after_initialize();
          if(recursive)
            component.initChildComponents();
        }
      });
    });
  }

  /** Clones #template and assigns the clone to #dom_element, then sets all the properties */
  initDomElementFromTemplate() {
    if(this.template != null) {
      this.dom_element = this.template.clone(true);
      this.dom_element.attributes.remove('data-component-template');
      this.dom_element.setAttribute('data-component-class', this.runtimeType.toString());
      attribute_names.forEach((a) => prvt_updatePropertyOnNode(a));
    }
  }

  /** Reloading obervable_roles.Subscriber's method.
    * 1. call the super() method to make sure the handler is applied.
    * 2. The actual code that adds new functionality:
    *    publish event to the parent with the current component roles.
    *
    * Only those events that are called on #self or self's parts (prefixed with "self.")
    * are propagated up to the parent.
  */
  captureEvent(e, publisher_roles, { data: null, prevent_default: false}) {
    if(!(e is String) && event_handlers.hasHandlerFor(event: e.type, role: publisher_roles)) {
      if(prevent_default)
        e.preventDefault();
      e = e.type;
    }
    super.captureEvent(e, publisher_roles, data: data);
    var roles_regexp = new RegExp(r"^self.");

    publisher_roles.forEach((r) {
      if(r == #self || roles_regexp.hasMatch(r.toString())) {
        this.publishEvent(e, data);
        return;
      }
    });
  }

  /** Reloading HeritageTree#add_child to automatically do the following things
    * when a child component is added:
    *
    * 1. Initialize a dom_element from template
    * 2. Append child's dom_element to the parent's dom_element.
    *
    * Obviously, you might not always want (2), so just redefine #_appendChildDomElement()
    * method in your class to change this behavior.
    */
  addChild(Component child) {
    _addValidationsToChild(child);
    // We only do it if this element is clearly not in the DOM.
    if(child.dom_element == null || child.dom_element.parent == null) {
      child.initDomElementFromTemplate();
      _appendChildDomElement(child.dom_element);
    }
    super.addChild(child);
  }

  /**
    * Removes itself from the parent's children List and removes the #dom_element
    * from the DOM. In case deep is set to true, recursively calls remove() on
    * all of its children.
    *
    * Makes use of _removeDomElement() to define specific behaviors to be invoked
    * when the #dom_element is being removed from the DOM. Default is to just use
    * HtmlElement#remove(), but one might want to redefine it to have animations of
    * some sort.
   */
  remove({ bool deep: false }) {
    if(deep) {
      this.children.forEach((c) => c.remove(deep: true));
      this.children = [];
    }
    if(this.parent != null) {
      if(!deep) // Otherwise we'd have a "Concurrent modification during iteration" error
        this.parent.removeChild(this);
      this.parent = null;
    }
    _removeDomElement();
    this.dom_element = null;
  }

  /** Finds immediate children with a specific role */
  findChildrenByRole(r) {
    var children_with_roles = [];
    for(var c in children) {
      if(c.roles.contains(r))
        children_with_roles.add(c);
    }
    return children_with_roles;
  }

  /** Finds all descendants with satisfy role path.
    * For example, if the current element has a child with role 'form' and
    * this child in turn has a child with role 'submit', then calling
    *
    *   findDescendantsByRole('form.submit')
    *
    * will find that child, but calling
    *
    *   findDescendantsByRole('submit')
    *
    * will NOT and would be equivalent to calling
    *
    *   findChildrenByRole('submit')
    *
    * returning an empty List [].
    *
   */
  findDescendantsByRole(r) {
    var role_path  = r.split('.');
    var child_role = role_path.removeAt(0);
    var children_with_roles = findChildrenByRole(child_role);
    if(role_path.length > 0) {
      var descendants_with_roles = [];
      for(var c in children_with_roles)
        descendants_with_roles.addAll(c.findDescendantsByRole(role_path.join('.')));
      return descendants_with_roles;
    } else {
      return children_with_roles;
    }
  }


  /** Reloads standart Validatable module method for two reasons:
    * 1. Collect all validation errors and write a String represenation of them
    *    to display somehwere in UI.
    * 2. Run validations on children too if deep is set to true.
    */
  @override
  validate({ deep: true }) {
    super.validate();

    try {
      if(!valid) {
        var validation_errors_summary_map = [];
        for(var ve in validation_errors.keys)
          validation_errors_summary_map.add("$ve: ${validation_errors[ve].join(' and ')}");
        this.validation_errors_summary = validation_errors_summary_map.join(', ');
      } else {
        this.validation_errors_summary = '';
      }
    }
    on NoSuchMethodError {
      // Ignore if no such attribute validation_errors_summary;
    }

    if(deep) {
      for(var c in this.children) {
        if(!c.validate(deep: true)) {
          valid = false;
          break;
        }
      }
    }
    return valid;
  }

  /** Finds first DOM descendant with a certain combination of attribute and its value,
   *  or returns the same node if that node has that combination.
   * 
   *  This method is needed when we want to listen to #dom_element's descendant native events
   *  or when a property is changed and we need to change a correspondent descendant node.
   */
  firstDomDescendantOrSelfWithAttr(node, { attr_name: null, attr_value: null }) {

    if(attr_name == null || node.getAttribute(attr_name) == attr_value)
      return node;
    else if(node.children.length == 0)
      return null;

    var el;
    for(var c in node.children) {
      if(c.getAttribute('data-component-class') == null) {
        el = firstDomDescendantOrSelfWithAttr(c, attr_name: attr_name, attr_value: attr_value);
        if(el != null)
          break;
      }
    }

    return el;

  }

  /** Calls a specific method on all of it's children. If method doesn't exist on one of the
    * children, ignores and doesn't raise an exception. This method is useful when we want to
    * communicate a common an action to all children, such as when we want to reset() all form
    * elements.
    */
  applyToChildren(method_name, [args=null]) {
    for(var c in children) {
      if(hasMethod(method_name, c))
        callMethod(method_name, c, args);
    }
  }

  /** Is run after a component is initialized by a parent component (but not manually).
    * Override this method in descendants.
    */
  after_initialize() {}

  /** Updates dom element's #text or attribute so it refelects Component's current property value. */
  prvt_updatePropertyOnNode(property_name) {
    if(this.dom_element == null)
      return;
    var property_el = this.firstDomDescendantOrSelfWithAttr(
        this.dom_element,
        attr_name: "data-component-property",
        attr_value: property_name
    );
    if(property_el != null) {
      // Basic case when property is tied to the node's text.
      property_el.text = this.attributes[property_name];
      // Now deal with properties tied to an element's attribute, rather than it's text.
      _updatePropertyOnHtmlAttribute(property_el, property_name);
    }
  }

  /** Finds the template HtmlElement in the dom and assigns it to #template */
  _initTemplate() {
    this.template = querySelector("[data-component-template=${this.runtimeType.toString()}");
  }

  /** Starts listening to native events defined in #native_events. It is
   *  called (and thus, listeners are re-initialized) if #dom_element changes.
   *  Native events may come from the #dom_element itself or from one of its descendants.
   *  Obviously, each native event has to be listed in #native_events for it to be caught.
   *
   *  If you want to catch events from descendants of the #dom_element, define events as
   *  "self.part_name" where part_name is identical to the value of the data-component-part
   *  html attribute of the descendant element.
   */
  _listenToNativeEvents() {
    this.native_events.forEach((e) {

      bool prevent_default = true;
      if(e.startsWith('!')) {
        e = e.substring(1);
        prevent_default = false;
      }

      // Event belongs to an html element which is a descendant of our component's dom_element
      if(e.contains('.')) {
        e = e.split('.'); // the original string is something like "text_field.click"
        var part_name  = e[0];
        var event_name = e[1];
        var part_el   = this.firstDomDescendantOrSelfWithAttr(
            this.dom_element,
            attr_name: 'data-component-part',
            attr_value: part_name
        );
        if(part_el != null) {
          part_el.on[event_name].listen((e) {
            this.captureEvent(e, ["self.$part_name"], prevent_default: prevent_default);
          });
        }
      }
      // Event belongs to our component's dom_element
      else {
        this.dom_element.on[e].listen((e) {
          this.captureEvent(e, [#self], prevent_default: prevent_default);
        });
      }
   }); 
  }

  /**
   * Creates behaviors by instantiation Behavior objects added into #behaviors list.
   * Called on Component intialization. Remember that Behavior objects must either
   * belong to the "nest_ui" library or be top level, otherwise the won't be found
   * and an error will be raised.
   */
  _createBehaviors() {
    behaviors.forEach((b) {
      [Component.app_library, 'nest_ui'].forEach((l) {
        var behavior_instance = new_instance_of(b.toString(), [this], l);
        if(behavior_instance != null)
          _behaviors.add(behavior_instance);
      });
    });
  }

  /** Sometimes properties are tied to HTML attributes, not to node's text. */
  _updatePropertyOnHtmlAttribute(node, attr_name) {
    var property_html_attr_name = node.getAttribute('data-component-property-attr-name');
    if(property_html_attr_name != null)
      node.setAttribute(property_html_attr_name, this.attributes[attr_name]);
  }

  _assignRolesFromDomElement() {
    var roles_attr = dom_element.getAttribute('data-component-roles');
    if(roles_attr != null)
      this.roles = dom_element.getAttribute('data-component-roles').split(new RegExp(r",\s?"));
  }

  /**  In order to be able to instatiate nested components, we need to find descendants of the #dom_element
    *  which have data-component-class attribute. This method takes care of that.
    */
  _findChildComponentDomElements(node) {
    List component_children = [];
    node.children.forEach((c) {
      if(c.getAttribute('data-component-class') == null)
        component_children.addAll(_findChildComponentDomElements(c));
      else
        component_children.add(c);
    });
    return component_children;
  }

  /** This method defines a default behavior when a new child is added.
    * Makes sense to append child dom_element to the parent's dom_element.
    * Of course, this might not always be desirable, so this method may be
    * redefined in descendant calasses.
    */
  _appendChildDomElement(HtmlElement el) {
    this.dom_element.append(el);
  }

  /** Defines behavior for removal of the #dom_element
    * Redefine this method to have something fancier (like an animation)
    * for when the #dom_element is removed.
    */
  _removeDomElement() {
    this.dom_element.remove();
  }

  /** Extracts validations with keys containing dots .
    * as those are validations defined for descendants.
    */
  _separateDescendantValidations() {
    for(var k in this.validations.keys) {
      if(k.contains('.')) {
        this.descendant_validations[k] = this.validations[k];
      }
    }
    for(var dv in this.descendant_validations.keys)
      this.validations.remove(dv);
  }

  /** Adds validations to children by looking at #descendants_validations.
    * Worth noting that if one of the validation keys contains more than one dot (.)
    * it means that this validation is for one of the child's children and it gets added
    * to child's #descendant_validations, not to #validations.
    */
  _addValidationsToChild(c) {
    for(var dr in this.descendant_validations.keys) {
      var dr_map = dr.split('.');
      var r      = dr_map.removeAt(0);
      if(c.roles.contains(r)) {
        if(dr_map.length > 1)
          c.descendant_validations[dr_map.join('.')] = this.descendant_validations[dr];
        else
          c.validations[dr_map[0]] = this.descendant_validations[dr];
      }
    }
  }

  // So far this is only required for Attributable module to work on this class.
  noSuchMethod(Invocation i) {  
    try {
      return prvt_noSuchGetterOrSetter(i);
    } on NoSuchAttributeException {
      super.noSuchMethod(i);
    }
  }

}
