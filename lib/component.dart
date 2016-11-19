part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable,
                                    Validatable,
                                    ComponentDom,
                                    ComponentHeritage,
                                    ComponentValidation,
                                    ComponentEventLock
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
  List native_events                = []; // native_events_list;
  List no_propagation_native_events = [];

  /** This is where Dart listeners for native events are stored, so we can cance
    * a listenere later, for example
    */
  Map native_event_listeners = {};

  /// a DOM element associated with this component
  HtmlElement _dom_element;

  /// Contains behavior classes from which objects are instantiated.
  /// You can add more, for example [... ButtonBehaviors, LinkBehaviors]
  List behaviors  = [BaseComponentBehaviors];
  /// instantiated behavior objects, don't touch it
  List behavior_instances = [];
  // If set to true and behavior object doesn't have the behavior being invoked, silently ignore that.
  // When set to false - raises a NoSuchMethodError!
  bool ignore_misbehavior = true;

  /// Translation instances (not null only if HtmlElement holding translation data are found).
  static Map i18n = {};

  /// Contains an element which will later be cloned and assigned to #dom_element
  /// if needed. Obviously, unless a real element from DOM isn't assigned.
  HtmlElement template;

  Component _root_component;

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

  /** Returns root_component by traversing the heritage tree until `#parent` property is empty.
    * Also cached the result, so it doesn't have to do it every time. After all,
    * in all likeihood root_component won't change.
    */
  get root_component {
    if(_root_component != null)
      return _root_component;
    _root_component = this.parent;
    while(_root_component != null && !(_root_component is RootComponent) && _root_component.parent != null)
      _root_component = _root_component.parent;
    return _root_component;
  }
  
  Component() {
    _separateDescendantValidations();
    _initTemplate();
    _loadI18n();
  }

  /** Invokes behaviors which are defined in separate Behavior objects. Those objects are instantiated
   *  when the constructor is called. If you want to define custom Behaviors, simply create
   *  a MyBehaviors class and add into the #behaviors list.
   */
  behave(behavior, [List attrs=null]) {
    if(attrs == null)
      attrs = [];
    for(var b in behavior_instances.reversed) {
      if(!ignore_misbehavior || methods_of(b).contains(behavior)) {
        var im = reflect(b);
        var result = im.invoke(new Symbol(behavior), attrs).reflectee;
        return result;
      }
    }
  }

  /** Reloading obervable_roles.Subscriber's method.
    * 1. call the super() method to make sure the handler is applied.
    * 2. The actual code that adds new functionality:
    *    publish event to the parent with the current component roles.
    *
    * Only those events that are called on #self are propagated up to the parent.
    * As of now, it was decided to exclude events from component parts to propagate
    * upwards - now the component itself is responsible for issuing publishEvent() calls
    * manually for each component part event handler.
  */
  @override bool captureEvent(e, publisher_roles, { data: null, prevent_default: false, is_native: false}) {

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

    // Only publish if event is the actual event of the dom_element, IS NOT
    // in non-propagate list, and is not a native event on one of the component parts.
    if(publisher_roles.contains(#self) && !no_propagation_native_events.contains(e)) {
      this.publishEvent(e, data);
      return;
    }

    return true;
  }

  /** Reloading the obervable_roles.Subscriber's method because
    * we need to make Component listen to its own events.
    * It's marginally useful, but is very helfpul in the implementation of
    * "children_initalized" event handler.
    */
  @override publishEvent(e,[data=null]) {
    if(this.event_handlers.hasHandlerFor(role: this, event: e))
      captureEvent(e, [this], data: data);
    super.publishEvent(e,data);
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

  /** This method is here because dart2js doesn't support super() calls in mixins.
    * Thus, the actual functionality is in _addChild() method inside the ComponentHeritage module
    * and this is just a front calling _addChild() and then super.addChild();
    */
  void addChild(child, { initialize: true }) {
    super.addChild(child);
    _addChild(child, initialize: initialize);
  }

  /** This method is here because dart2js doesn't support super() calls in mixins.
    * Thus, the actual functionality is in _validate() method inside the ComponentValidation module
    * and this is just a front calling _validate() and then super.validate();
    */
  bool validate({deep: true}) {
    super.validate();
    return _validate(deep: deep);
  }

  /** Is run after a component is initialized by a parent component (but not manually).
    * Override this method in descendants, but don't forget to call super() inside, or
    * you'll be left without behaviors!
    */
  void afterInitialize() {
    this.setDefaultAttributeValues();
    _createBehaviors();
  }

  /** A convenience method for creating an event handler for when parent is done initializing itself and all of its
    * children. `my_role` argument is used to uniquely identify a component. Could be dynamically generated
    * so that only this particular instance of Component is tracked by the parent. See `HintComponent` for example
    * of the usage. */
  afterParentInitialized(my_role, handler) {
    this.parent.roles.add(my_role);
    this.parent.addObservingSubscriber(this);
    event_handlers.add(event: "initialized", role: my_role, handler: handler);
  }

  void afterChildrenInitialize() {}

  /** Sometimes we need to re-create all or some event listeners for native events. This
    * is usually necessary when new elements are added onto the page - previously created
    * listeners don't really monitor them. This method is created for this specific reason.
    *
    * This method first gets read of ALL existing listeners, the creates new listeners
    * for all events listed in `native_events` property.
    *
    * TODO: potential improvement would be to only cancel and re-create native events
    * for parts because it is unlikely we'll remove the dom_element itself.
    */
  void reCreateNativeEventListeners() {
    _cancelEventListeners();
    _listenToNativeEvents();
  }

  /** Finds the translation for the provided key using either its own translator or
    * RootComponent's translator. */
  String t(String key) {
    var i18n      = Component.i18n[getTypeName(this)];
    var i18n_root = Component.i18n["RootComponent"];
    var translation;
    if(i18n != null)
      translation = i18n.t(key);
    if(translation == null && i18n_root != null)
        translation = i18n_root.t(key);
    
    if(translation == null)
      translation = "WARNING: Translation missing for \"$key\"";

    return translation;
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

      var original_native_event_name = e;

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
          this.native_event_listeners[original_native_event_name] = [];
          for(var part_el in part_els) {
            this.native_event_listeners[original_native_event_name].add(
              part_el.on[event_name].listen((e) {
                this.captureEvent(e, ["self.$part_name"], prevent_default: prevent_default, is_native: true);
              })
            );
          }
        }
      }
      // Event belongs to our component's dom_element
      else {
        this.native_event_listeners[original_native_event_name] = this.dom_element.on[e].listen((e) {
          this.captureEvent(e, [#self], prevent_default: prevent_default, is_native: true);
        });
      }
    }); 
  }

  /** Cancels all existing event listeners for all native events
    * listed in `native_events` property.
    *
    * An optional List argument can be provided, in which case only
    * event listeners listed in it will be cancelled.
    */
  void _cancelEventListeners([List event_names=null]) {
    if(event_names == null) {
      this.native_event_listeners.forEach((k,v) => _cancelEventListenersForEventName(v));
      this.native_event_listeners = {};
    }
    else {
      event.names.forEach((e) {
        _cancelEventListenersForEventName(this.native_event_listeners[e]);
        this.native_event_listeners.remove(e);
      });
    }
  }

  /** This one primarily takes care of whether an object in #native_event_listener is
    * a Subscription or a List of Subscriptions and acts accordingly.
    * It may be a List of subscriptions for events for Component parts and a
    * Subscription object itself for the native events on #dom_element.
    */
  void _cancelEventListenersForEventName(event) {
    if(event is List)
      event.forEach((e) => e.cancel());
    else
      event.cancel();
  }

  /**
   * Creates behaviors by instantiation Behavior objects added into #behaviors list.
   * Called on Component intialization. Remember that Behavior objects must either
   * belong to the "nest_ui" library or be top level, otherwise the won't be found
   * and an error will be raised.
   */
  void _createBehaviors() {
    if(this.behavior_instances.length > 0)
      return;
    behaviors.forEach((b) {
      var behavior_instance = new_instance_of(b.toString(), [this], [Component.app_library, 'nest_ui']);
      if(behavior_instance != null)
        behavior_instances.add(behavior_instance);
    });
  }

  void _loadI18n() {
    var i18n = new I18n("i18n_${getTypeName(this)}");
    if(i18n != null) {
      i18n.print_console_warning = false;
      Component.i18n[getTypeName(this)] = i18n;
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
