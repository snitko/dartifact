part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable,
                                    Validatable,
                                    ComponentDomFunctions,
                                    ComponentHeritageFunctions,
                                    ComponentValidationFunctions
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
  List behavior_instances = [];
  // If set to true and behavior object doesn't have the behavior being invoked, silently ignore that.
  // When set to false - raises a NoSuchMethodError!
  bool ignore_misbehavior = true;

  /** Event locks allow you to prevent similar events being handled twice
    * until the lock is removed. This is useful, for example, to prevent
    * button being clicked twice and, consequently, a form being submitted twice.
    */
  /// Defines which events to use locks for
  List event_lock_for = [];
  /// Stores the locks themselves. If event name is in this List, it's locked.
  List event_locks    = [];

  /// Contains an element which will later be cloned and assigned to #dom_element
  /// if needed. Obviously, unless a real element from DOM isn't assigned.
  HtmlElement template;

  /** This one is important if you intend to separate your app
    * into many parts (files). In that case, you'll need to declare a library.
    * Component then will look for its children in 'nest_ui' library as well as
    * app_library. Due to how Dart works, it's impossible to lookup for class names
    * without knowing which library do they belong. Thus, it's either '' (top level)
    * or your app_library name.
    */
  static String app_library = '';

  Map attribute_callbacks = {
    'default' : (attr_name, self) => self.attribute_callbacks_collection['write_property_to_dom'](attr_name, self)
  };
  final Map attribute_callbacks_collection = {
    'write_property_to_dom' : (attr_name, self) => self.prvt_writePropertyToNode(attr_name)
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
    _initTemplate();
  }

  /** Invokes behaviors which are defined in separate Behavior objects. Those objects are instantiated
   *  when the constructor is called. If you want to define custom Behaviors, simply create
   *  a MyBehaviors class and add into the #behaviors list.
   */
  void behave(behavior) {
    behavior_instances.forEach((b) {
      if(!ignore_misbehavior || methods_of(b).contains(behavior)) {
        var im = reflect(b);
        im.invoke(new Symbol(behavior), []);
        return;
      }
    });
  }

  /** Reloading obervable_roles.Subscriber's method.
    * 1. call the super() method to make sure the handler is applied.
    * 2. The actual code that adds new functionality:
    *    publish event to the parent with the current component roles.
    *
    * Only those events that are called on #self or self's parts (prefixed with "self.")
    * are propagated up to the parent.
  */
  bool captureEvent(e, publisher_roles, { data: null, prevent_default: false, is_native: false}) {

    // For native events, pass the Event object in data
    if(data == null && e is Event && is_native)
      data = e;

    var event_obj = e;
    if(!(e is String)) {
      if(event_handlers.hasHandlerFor(event: e.type, role: publisher_roles) && prevent_default)
        e.preventDefault();
      e = e.type;
    }

    if(hasEventLock(e, publisher_roles: publisher_roles)) {
      event_obj.preventDefault();
      return false;
    }
    addEventLock(e, publisher_roles: publisher_roles);

    super.captureEvent(e, publisher_roles, data: data);
    var roles_regexp = new RegExp(r"^self.");

    publisher_roles.forEach((r) {
      if(r == #self || roles_regexp.hasMatch(r.toString())) {
        this.publishEvent(e, data);
        return;
      }
    });

    return true;
  }

  /** Adds a new event lock. In case the event name is not on the event_lock_for List,
      the lock wouldn't be set. If you want the lock to be set anyway,
      just use the event_locks property directly.
   */
  void addEventLock(event_name, { publisher_roles: null }) {
    var event_names = _prepareFullEventNames(event_name, publisher_roles);
    if(event_locks.toSet().intersection(event_names).isEmpty) {
      if(event_lock_for.contains(event_name))
        event_names.forEach((en) => event_locks.add(en));
    }

  }

  bool hasEventLock(event_name, { publisher_roles: null }) {
    var event_names = _prepareFullEventNames(event_name, publisher_roles);
    if(event_locks.contains(#any) || !(event_locks.toSet().intersection(event_names).isEmpty))
      return true;
    else
      return false;
  }

  Set _prepareFullEventNames(event_name, [publisher_roles=null]) {
    var event_names = new Set();
    publisher_roles.forEach((r) {
      if(r == #self)
        event_names.add(event_name);
      else
        event_names.add("$r.$event_name");
    });
    return event_names;
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
  void remove({ bool deep: false }) {
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

  /** Is run after a component is initialized by a parent component (but not manually).
    * Override this method in descendants, but don't forget to call super() inside, or
    * you'll be left without behaviors!
    */
  void afterInitialize() {
    _createBehaviors();
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
  void _listenToNativeEvents() {
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
        var part_els   = this.allDomDescendantsAndSelfWithAttr(
          this.dom_element,
          attr_name: 'data-component-part',
          attr_value: part_name
        );
        if(part_els != null && part_els.length > 0) {
          for(var part_el in part_els) {
            part_el.on[event_name].listen((e) {
              this.captureEvent(e, ["self.$part_name"], prevent_default: prevent_default, is_native: true);
            });
          }
        }
      }
      // Event belongs to our component's dom_element
      else {
        this.dom_element.on[e].listen((e) {
          this.captureEvent(e, [#self], prevent_default: prevent_default, is_native: true);
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
  void _createBehaviors() {
    behaviors.forEach((b) {
      [Component.app_library, 'nest_ui'].forEach((l) {
        var behavior_instance = new_instance_of(b.toString(), [this], l);
        if(behavior_instance != null)
          behavior_instances.add(behavior_instance);
      });
    });
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
