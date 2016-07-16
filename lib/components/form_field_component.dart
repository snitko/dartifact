part of nest_ui;

class FormFieldComponent extends Component {

  List   native_events   = ["value_holder.change", "change"];
  String value_property  = 'value';
  List   attribute_names = ["validation_errors_summary"];
  List   behaviors       = [FormFieldComponentBehaviors];

  FormFieldComponent() {

    attribute_names.add(value_property);

    event_handlers.addForEvent('change', {
        #self:               (self) => self.prvt_updateValueFromDom(),
        'self.value_holder': (self) => self.prvt_updateValueFromDom()
      }
    );

  }

  @override
  validate({ deep: true }) {
    super.validate();
    this.valid ? this.behave('hideErrors') : this.behave('showErrors');
    return valid;
  }

  reset() {
    this.value = null;
    value_holder_element.value = null;
  }

  get value_holder_element {
    var value_holder = this.firstDomDescendantOrSelfWithAttr(
      this.dom_element, attr_name: 'data-component-part', attr_value: 'value_holder'
    );
    if(value_holder == null)
      value_holder = this.dom_element;
    return value_holder;
  }

  prvt_updateValueFromDom() {
    this.updateAttributes({ "$value_property" : value_holder_element.value });
  }


}
