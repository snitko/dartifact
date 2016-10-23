part of nest_ui;

class SimpleNotificationComponent extends Component with AutoShowHide {

  final List attribute_names = ["message", "autohide_delay", "permanent", "container_selector"];
        List native_events   = ["close.click"];
        Map default_attribute_values = {
          "container_name": "#simple_notifications_container",
          "permanent": false,
          "autohide_delay": 10
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
    this.show();
  }

  void show() {
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
