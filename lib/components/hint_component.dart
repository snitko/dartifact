part of nest_ui;

class HintComponent extends Component {

  List native_events   = ["close.click", "close_and_never_show.click"];
  List attribute_names = ["anchor", "show_events", "force_show_events", "autodisplay_delay",
                          "autohide_delay", "display_limit", "keep_open_when_hover", "hint_id"];

  var _anchor_object;
  List anchor_events = [];

  Map default_attribute_values = {
    "keep_visible_when_hover": true,
    "display_limit" : null
  };

  bool visible = false;

  HintComponent() {}

  void afterInitialize() {
    super.afterInitialize();

    updatePropertiesFromNodes();

    //-------------------------------------------------------------------------------/
    // This piece of code makes sure we only start adding event handlers once ALL
    // of the child components of the parent(!) component are loaded. A special
    // "children_initialized" event is published by parent, which we make use of here.

    // If we tried adding event handlers outside of "children_initialized" handler,
    // chances are, anchor_object might have been nil.
    //-------------------------------------------------------------------------------/
    this.parent.roles.add("${this.hint_id}_parent");
    this.parent.addObservingSubscriber(this);

    event_handlers.add(event: "children_initialized", role: "${this.hint_id}_parent", handler: (self,publisher) {

      if(this.anchor_object is HtmlElement) {

        if(!isBlank(this.show_events))
          _createNativeShowEvents(this.show_events.split(","), () => show());
        if(!isBlank(this.force_show_events))
          _createNativeShowEvents(this.force_show_events.split(","), () => show(force: true));

      } else if(this.anchor_object is Component) {

        this.anchor_object.addObservingSubscriber(this);
        if(!isBlank(this.show_events))
          _createChildComponentsShowEvents(this.show_events.split(","), (self,publisher) => show());
        if(!isBlank(this.force_show_events))
          _createChildComponentsShowEvents(this.force_show_events.split(","), (self,publisher) => show(force: true));

      }

    });
    //-------------------------------------------------------------------------------/

    // If autodisplay_delay is set
      // 3. Create a timer
      // 4. Call show()

  }

  void afterAllChildrenInitialized() {
  
  }

  void show({force: false}) {
    if(!this.isDisplayLimitReached || force) {
      if(!force)
        incrementDisplayLimit();
      this.visible = true;
    }

    behave("show");

    // If autohide_delay is set
      // 3. Create a timer
      // 4. Call hide() behavior
  }

  void hide() {
    behave("hide");
    this.visible = false;
  }

  void incrementDisplayLimit() {
    var i = times_displayed + 1;
    if(!this.isDisplayLimitReached)
      cookie.set("hint_${hint_id}", i.toString(), expires: 1780);
  }

  bool get isDisplayLimitReached {
    return this.display_limit != null && this.display_limit <= this.times_displayed;
  }

  get times_displayed {
    var i = cookie.get("hint_${this.hint_id}");
    if(i == null)
      return 0;
    else
      return int.parse(i);
  }

  get anchor_object {

    var anchor_name_arr = this.anchor.split(":");
    switch(anchor_name_arr[0]) {
      case "part":
        _anchor_object = parent.findPart(anchor_name_arr[1]);
        break;
      case "property":
        _anchor_object = parent.findFirstPropertyElement(anchor_name_arr[1]);
        break;
      case "role":
        _anchor_object = parent.findFirstChildByRole(anchor_name_arr[1]);
        break;
      default:
        _anchor_object = parent.firstDomDescendantOrSelfWithAttr(parent.dom_element, attr_name: "id", attr_value: anchor_name_arr[0]);
    }

    return _anchor_object;
  }

  _createNativeShowEvents(List events, handler) {
    events.forEach((event_name) {
      anchor_events.add(this.anchor_object.on[event_name].listen((e) => handler()));
    });
  }

  _createChildComponentsShowEvents(List events, handler) {
    events.forEach((event_name) {
      event_handlers.add(event: event_name, role: this.anchor.split(":")[1], handler: handler);
    });
  }

}
