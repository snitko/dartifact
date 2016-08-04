part of nest_ui;

class NumericFormFieldComponent extends FormFieldComponent {

  List native_events   = ["!value_holder.keyup"];
  List attribute_names = ["validation_errors_summary", "name", "disabled"];

  NumericFormFieldComponent() {
    event_handlers.add(event: 'keyup', role: 'self.value_holder', handler: (self,event) {
      prvt_updateValueFromDom();
    });
  }

  afterInitialize() {
    updatePropertiesFromNodes(attrs: ["value", "disabled", "name"], invoke_callbacks: true);
  }

  @override
  set value(v) {
    var numeric_regexp = new RegExp(r"^\d*$");
    if(numeric_regexp.hasMatch(v)) {
      this.attributes["value"] = v;
      this.publishEvent("change", this);
    }
    else
      this.value_holder_element.value = this.value;
  }

  @override
  prvt_updateValueFromDom() {
    this.value = value_holder_element.value;
  }

}
