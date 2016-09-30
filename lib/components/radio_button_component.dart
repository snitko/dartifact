part of nest_ui;

// Extends Component and FormFieldComponent, because there isn't any value holder element
class RadioButtonComponent extends Component {

  List native_events   = ["option.change"];
  List attribute_names = ["validation_errors_summary", "disabled", "value"];
  Map options          = {};

  RadioButtonComponent() {

    event_handlers.add(event: 'change', role: "self.option", handler: (self,event) {
      self.setValueFromOptions(event.target);
    });

    attribute_callbacks["value"] = (self, name) => selectOptionFromValue();
  
  }

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["disabled", "name"], invoke_callbacks: true);
    findAllParts("option").forEach((p) => this.options[p.value] = p);
    if(isBlank(this.value))
      setValueFromSelectedOption();
    else
      selectOptionFromValue();
 }

  void selectOptionFromValue() {
    if(this.options.keys.contains(this.value)) {
      this.options.values.forEach((el) => el.checked = false);
      this.options[this.value].checked = true;
    } else if(!isBlank(this.value)) {
      throw new NoOptionWithSuchValue("No option found with value `${this.value}`. You can't set a value that's not in the this.options.keys List.");
    }
  }

  void setValueFromOptions(option_el) {
    if(option_el.checked) {
      this.attributes["value"] = option_el.value;
      this.publishEvent("change", this);
    }
  }

  void setValueFromSelectedOption() {
    options.values.forEach((o) {
      if(o.checked)
        this.value = o.value;
    });
  }

}

class NoOptionWithSuchValue implements Exception {
  String cause;
  NoOptionWithSuchValue(this.cause);
}
