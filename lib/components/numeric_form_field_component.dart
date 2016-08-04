part of nest_ui;

class NumericFormFieldComponent extends FormFieldComponent {

  List native_events = ["!value_holder.keyup"];

  NumericFormFieldComponent() {
    event_handlers.add(event: 'keyup', role: 'self.value_holder', handler: (self,event) {
      prvt_updateValueFromDom();
    });
  }

  @override
  set value(v) {
    var numeric_regexp = new RegExp(r"^\d*$");
    if(numeric_regexp.hasMatch(v))
      this.attributes["value"] = v;
    else
      this.value_holder_element.value = this.value;
  }

  @override
  prvt_updateValueFromDom() {
    this.value = value_holder_element.value;
  }

}
