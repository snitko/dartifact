part of nest_ui;

/** The purpose of this component is rather simple - display popup hints over other elements on the page
  * whenever an event happens to this element: user clicks the element or hovers over it or something else.
  *
  * Properties description:
  *
  *   * `anchor` - An anchor is an element in DOM or another component to which events the hint will be listening to.
  *   Normally, you'd want to specify value for the #anchor property in a corresponding attribute to the hint's dom_element.
  *   See description for `#anchor_element` getter to learn more.
  *
  *   * `show_events`, `force_show_events` - These two properties specify on which anchor events the hint appears.
  *   The `show_events` only works if the display_limit isn't reached or if the hint isn't
  *   permanently closed (never_show_again flag is set). The `force_show_events events` will force the hint to appear
  *   regardless of the limitations mentioned above.
  *
  *   * `autoshow_delay`, `autohide_delay` - These two properties are rather self descriptive. Their value is time in seconds.
  *   By default, they're both null so hints are not show unless a specified event occurs on an anchor
  *   and they don't hide unless the user explicitly closes them by clicking on the close button.
  *
  *   * `display_limit` - You don't want to annoy your users by showing them hints every time they visit the page and, for example,
  *   happen to mouseover the anchor. In that case, you'll need set the display_limit property to something sensible.
  *
  *   * `hint_id` - The number of times a hint was displayed is saved in a cookie, which needs to uniquely identify a particular HintComponent.
  *   For this reason it is important to have a #hint_id (data-hint-id) set to a unique value.
  *
  */
class HintComponent extends Component with AutoShowHide {

  List native_events   = ["close.click", "close_and_never_show.click"];
  List attribute_names = ["anchor", "show_events", "force_show_events", "autoshow_delay",
                          "autohide_delay", "display_limit", "hint_id"];

  var _anchor_object;
  Future autoshow_future, autohide_future;
  List anchor_events = [];
  bool visible       = false;
  List behaviors     = [HintComponentBehaviors];

  Map default_attribute_values = {
    "display_limit": null,
    "show_events": "click"
  };

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

      autoshow();

    });

    event_handlers.addForEvent("click", {
      "self.close":                (self,event) => self.hide(),
      "self.close_and_never_show": (self,event) => self.hide(never_show_again: true)
    });

  }

  /** This method not only invokes the show() behavior,
    * but rather makes a check whether the display limit was reached,
    * updates said limit and sets autohide if applicable.
    */
  void show({force: false}) {

    if(!this.isDisplayLimitReached || force) {
      hideOtherHints();
      if(!force)
        incrementDisplayLimit();
      behave("show");
      this.visible = true;
      autohide();
    }

  }

  /** Hides the hint and in case it's being closed with `close_and_never_show` part,
    * sets the appropriate cookie to indicate the hint shouldn't be displayed again.
    */
  void hide({ never_show_again: false}) {
    behave("hide");
    this.visible = false;
    if(never_show_again)
      cookie.set("hint_${hint_id}_never_show_again", "1", expires: 1780);
  }

  /** It's important to not bloat user's screen with many hints. That's why we want to hide
    * all other hints when displaying the current one.
    */
  void hideOtherHints() {
    this.root_component.findAllDescendantInstancesOf(getTypeName(this)).forEach((d) {
      if(this != d && d.visible) {
        d.hide();
      }
    });
  }

  /** Increments the display_limit counter and updates the corresponding cookie */
  void incrementDisplayLimit() {
    var i = times_displayed + 1;
    if(!this.isDisplayLimitReached)
      cookie.set("hint_${hint_id}", i.toString(), expires: 1780);
  }

  /** Checks whether the display_limit was reached.
    * Takes into account never_show_again flag (it's a cookie): if it's set, the answer is always true.
    */
  bool get isDisplayLimitReached {
    return (cookie.get("hint_${this.hint_id}_never_show_again") == "1") || this.display_limit != null && this.display_limit <= this.times_displayed;
  }

  /** Retrieves the cookie and shows how many times this hint was displayed.
    * Substitutes null for 0 in case the cookie is non-existent.
    */
  get times_displayed {
    var i = cookie.get("hint_${this.hint_id}");
    if(i == null)
      return 0;
    else
      return int.parse(i);
  }

  /** An anchor is an element in DOM or another component to which events the hint will be listening to.
    * Normally, you'd want to specify value for the #anchor property in a corresponding attribute to the hint's dom_element.
    * This getter takes the `#anchor` value, parses it and finds an object to be returned:
    * it will either be a `Component` or an `HtmlElement`.
    *
    * It is possible to specify anchors by their distinctive characteristics:
    *
    *   - By role: the prefix is `role:`. Example: `role:submit`.
    *   - By property name: the prefix is `property:`. Example: `property:caption`
    *   - By part name: the prefix is `part:`. Example: `part:input_value`
    *   - By DOM element id: then the prefix is ommited Example: `submit_form_button`
    *   - When specifying a role, you can also specify this role component's part: `role:button:caption`
    */
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
        if(anchor_name_arr.length == 2)
          _anchor_object = parent.findFirstChildByRole(anchor_name_arr[1]);
        else if(anchor_name_arr.length == 3)
          _anchor_object = parent.findFirstChildByRole(anchor_name_arr[1]).findPart(anchor_name_arr[2]);
        break;
      default:
        _anchor_object = parent.firstDomDescendantOrSelfWithAttr(parent.dom_element, attr_name: "id", attr_value: anchor_name_arr[0]);
    }

    return _anchor_object;
  }

  /** In cases when anchor_object returns an instance of `Component`, this
    * getter makes sure it returns the `#dom_element` of that component.
    * Otherwise it returns the same `HtmlElement` returned by `#anchor_object`.
    */
  get anchor_el {
    if(anchor_object is Component)
      return anchor_object.dom_element;
    else
      return anchor_object;
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
