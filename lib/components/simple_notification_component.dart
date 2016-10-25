part of nest_ui;

class SimpleNotificationComponent extends Component with AutoShowHide {

  final List attribute_names = ["message", "autohide_delay", "permanent", "container_selector", "message_type", "ignore_duplicates"];
        List native_events   = ["close.click"];
        Map default_attribute_values = {
          "container_name": "#simple_notifications_container",
          "permanent": false,
          "autohide_delay": 10,
          "message_type": "neutral",
          "ignore_duplicates": true
        };

  Future autohide_future;

  List behaviors = [SimpleNotificationComponentBehaviors];
  bool visible   = false;
  HtmlElement container;

  SimpleNotificationComponent({ attrs: null }) {
    updateAttributes(attrs);
    this.container = querySelector("#simple_notifications_container");
    event_handlers.add(event: "click", role: "self.close", handler: (self, event) => self.hide());
  }

  @override void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes();

    if(this.permanent == true)
      this.behave("hideCloseButton");

    this.show();
  }

  void show() {

    // Don't do anything if a similar message has been displayed before.
    if(this.ignore_duplicates && this.parent != null) {
      var has_duplicate = false;
      this.root_component.findAllDescendantInstancesOf(getTypeName(this)).forEach((n) {
        if(n.message == this.message && n != this)
          has_duplicate = true;
      });
      if(has_duplicate) {
        this.hide();
        return;
      }
    }

    behave("show");
    this.visible = true;
    autohide();
  }

  void hide() {
    if(this.permanent == null || this.permanent == false) {
      behave("hide");
      this.visible = false;
      this.parent.removeChild(this);
    }
  }

}
