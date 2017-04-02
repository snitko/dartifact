part of nest_ui;

/** RadioButton is a widely used UI element and this component simply provides a wrapper in the
  * the form of Component for NestUI. There are methods to set value from the current value of the
  * radio element & set radio element value from RadioButtonComponent#value (a backwards operation).
  * 
  * It extends Component and NOT FormFieldComponent, because there isn't any value holder element.
  *
  * Properties description:
  *
  *   * `validation_errors_summary`, `disabled`- same as in FormFieldComponent.
  *   * `value` - is set when a particular option is chosen.
  */
class RadioButtonComponent extends Component {

  List native_events   = ["option.change"];
  List attribute_names = ["validation_errors_summary", "disabled", "value"];
  Map default_attribute_values = { "disabled" : false };

  /** Stores all options and their values. Filled with data from the DOM-structure upon initialization. */
  Map options = {};

  RadioButtonComponent() {

    event_handlers.add(event: 'change', role: "self.option", handler: (self,event) {
      self.setValueFromOptions(event.target);
    });

    attribute_callbacks["value"]    = (self, name) => selectOptionFromValue();
    attribute_callbacks["disabled"] = (self, name) => toggleDisabled();
  
  }
  
  get value {
    if(this.attributes["value"] != null)
      return this.attributes["value"].toString();
  }

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["name", "value"], invoke_callbacks: false);
    updatePropertiesFromNodes(attrs: ["disabled"], invoke_callbacks: true);
    findAllParts("option").forEach((p) => this.options[p.value] = p);
    if(isBlank(this.value))
      setValueFromSelectedOption();
    else
      selectOptionFromValue();
  }

  /** Selects the radio button (makes it checked visually) based on the #value of the instance.
    * If an option with such value doesn't exist, throws an error.
    */
  void selectOptionFromValue() {
    if(this.options.keys.contains(this.value)) {
      this.options.values.forEach((el) => el.checked = false);
      this.options[this.value.toString()].checked = true;
      this.publishEvent("change", this);
    } else if(!isBlank(this.value)) {
      throw new NoOptionWithSuchValue("No option found with value `${this.value}`. You can't set a value that's not in the this.options.keys List.");
    }
  }

  /** When a radio button is clicked, we need to set the #value of the current RadioButtonComponent instance.
    * That's what this method does. The problem is, a radio element apparantely creates multiple click events
    * so we need to only react to one single event that's invoked on the radio button being selected - thus the
    * additional `if` inside.
    */
  void setValueFromOptions(HtmlElement option_el) {
    if(option_el.checked) {
      this.attributes["value"] = option_el.value;
      this.publishEvent("change", this);
    }
  }

  /** This method is used to set the default #value for the RadioButtonComponent instance when our Radio is already checked on page load. */
  void setValueFromSelectedOption() {
    options.values.forEach((o) {
      if(o.checked)
        this.value = o.value;
    });
  }

  /* TODO: should instead be in behaviors */
  void toggleDisabled() {
    findAllParts("option").forEach((option) {
      if(this.disabled)
        option.attributes["disabled"] = "disabled";
      else
        option.attributes.remove("disabled");
    });
  }

}

class NoOptionWithSuchValue implements Exception {
  String cause;
  NoOptionWithSuchValue(this.cause);
}
