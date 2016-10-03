part of nest_ui;

class HintComponent extends Component {

  List native_events   = ["close.click", "close_and_never_show.click"];
  List attribute_names = ["anchor", "open_events", "force_open_events", "autodisplay_delay",
                          "autohide_delay", "display_times_limit", "keep_open_when_hover", "hint_id"];

  var _anchor_object;

  Map default_attribute_values = {
    "keep_open_when_hover": true,
    "display_times_limit" : 0
  };

  bool visible = false;

  HintComponent() {}

  void afterInitialize() {
    super.afterInitialize();

    // 1. Find anchor in parent
    // 2. Create events for it

    // If autodisplay_delay is set
      // 3. Create a timer
      // 4. Call show()

  }

  void show({force: false}) {
    // 1. Check if display times limit is reached.
    // 2. Set visible to true
    // 3. Call behavior
    // 4. Update display_times_limit

    // If autohide_delay is set
      // 3. Create a timer
      // 4. Call hide() behavior
  }

  void hide() {
    // 1. Set visible to false
    // 2. Call behavior 
  }

  void updateDisplayLimit() {}
  bool isDisplayLimitReached() {}

  get anchor_object {

    if(_anchor_object != null)
      return _anchor_object;

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


}
