part of dartifact;

class CheckboxComponent extends Component {
  List native_events = ["change"];
  List attribute_names = ["name", "disabled", "checked"];

  Map default_attribute_values = { "disabled": false, "checked": false };

  CheckboxComponent() {
    event_handlers.add(event: "change", handler: (self, event) {
      self.checked = event.target.checked;
    });

    this.attribute_callbacks["checked"] = (attr_name, self) {
      if (self.checked)
        self.behave("check");
      else
        self.behave("uncheck");
    };
  }

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["name", "checked", "disabled"], invoke_callbacks: false);
  }

  @override get value => this.checked == "checked" || this.checked;

  @override set value(v) {
    this.checked = v;
  }
}
