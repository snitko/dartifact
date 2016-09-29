part of nest_ui;

// Extends Component and FormFieldComponent, because there isn't any value holder element
class RadioButtonComponent extends Component {

  List native_events   = ["option.change"];
  List attribute_names = ["validation_errors_summary", "name", "disabled", "value"];
  Map  options         = {};

  RadioButtonComponent() {

    event_handlers.add(event: 'change', role: "self.option", handler: (self,event) {
      self.prvt_setValueFromOptions(event.target);
    });
  
  }

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["disabled", "name"], invoke_callbacks: true);
    selectOptionFromValue();
    // Load all options from DOM into options Map: value => dom_el;
 }

  void selectOptionFromValue() {
    // 1. Find option with current value
    // 2. Select this option
  }

  void _setValueFromOptions(radio_button_element) {
    // 1. Check if this option is checked or not
    // 2. Set new value to the value of the checked option
  }

}
