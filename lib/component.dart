part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable
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
    _listenToNativeEvents();
  }
  
  Component() {
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
      ['', 'nest_ui'].forEach((l) {
        var component = new_instance_of(el.getAttribute('data-component-class'), l);
        if(component != null) {
          component.dom_element = el;
          this.addChild(component);
          if(recursive)
            component.initChildComponents();
        }
      });
    });
  }

  /** Clones #template and assigns the clone to #dom_element, then sets all the properties */
  initDomElementFromTemplate() {
    this.dom_element = template.clone(true);
    this.dom_element.attributes.remove('data-component-template');
    this.dom_element.setAttribute('data-component-class', this.runtimeType.toString());
    attribute_names.forEach((a) => prvt_updatePropertyOnNode(a));
  }

  /** Updates dom element's #text or attribute so it refelects Component's current property value. */
  prvt_updatePropertyOnNode(property_name) {
    var property_el = _firstDescendantOrSelfWithAttr(
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
      // Event belongs to an html element which is a descendant of our component's dom_element
      if(e.contains('.')) {
        e = e.split('.'); // the original string is something like "text_field.click"
        var part_name  = e[0];
        var event_name = e[1];
        var part_el   = _firstDescendantOrSelfWithAttr(
            this.dom_element,
            attr_name: 'data-component-part',
            attr_value: part_name
        );
        if(part_el != null) {
          part_el.on[event_name].listen((e) => this.captureEvent(e.type, ["self.$part_name"]));
        }
      }
      // Event belongs to our component's dom_element
      else {
        this.dom_element.on[e].listen((e) => this.captureEvent(e.type, [#self]));
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
      ['', 'nest_ui'].forEach((l) {
        var behavior_instance = new_instance_of(b.toString(), l);
        if(behavior_instance != null) {
          behavior_instance.component = this;
          _behaviors.add(behavior_instance);
        }
      });
    });
  }

  /** Sometimes properties are tied to HTML attributes, not to node's text. */
  _updatePropertyOnHtmlAttribute(node, attr_name) {
    var property_html_attr_name = node.getAttribute('data-component-property-attr-name');
    if(property_html_attr_name != null)
      node.setAttribute(property_html_attr_name, this.attributes[attr_name]);
  }

  /** Finds first DOM descendant with a certain combination of attribute and its value,
   *  or returns the same node if that node has that combination.
   * 
   *  This method is needed when we want to listen to #dom_element's descendant native events
   *  or when a property is changed and we need to change a correspondent descendant node.
   */
  _firstDescendantOrSelfWithAttr(node, { attr_name: null, attr_value: null }) {

    if(attr_name == null || node.getAttribute(attr_name) == attr_value)
      return node;
    else if(node.children.length == 0)
      return null;

    var el;
    node.children.forEach((c) {
      if(c.getAttribute('data-component-id') == null) {
         el = _firstDescendantOrSelfWithAttr(c, attr_name: attr_name, attr_value: attr_value);
      }
    });

    return el;

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

  // So far this is only required for Attributable module to work on this class.
  noSuchMethod(Invocation i) {  
    try {
      return prvt_noSuchGetterOrSetter(i);
    } on NoSuchAttributeException {
      super.noSuchMethod(i);
    }
  }

}
