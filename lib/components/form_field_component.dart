part of nest_ui;

class FormFieldComponent extends Component {

  List   native_events   = ["value_holder.change", "change", "!value_holder.keyup"];
  String value_property  = 'value';
  List   attribute_names = ["validation_errors_summary", "name", "disabled"];
  List   behaviors       = [FormFieldComponentBehaviors];

  FormFieldComponent() {

    attribute_names.add(this.value_property);
    attribute_callbacks[this.value_property] = (attr_name, self) {
      prvt_setValueForValueHolderElement(self.attributes[self.value_property]);
      self.publishEvent("change", self);
    };

    event_handlers.addForEvent('change', {
        #self:               (self,event) => self.prvt_updateValueFromDom(),
        'self.value_holder': (self,event) => self.prvt_updateValueFromDom()
      }
    );

    event_handlers.add(event: 'keyup', role: 'self.value_holder', handler: (self,event) {
      prvt_updateValueFromDom();
    });

  }

  void afterInitialize() {
    super.afterInitialize();
    prvt_updateValueFromDom();
  }

  @override
  bool validate({ deep: true }) {
    super.validate();
    return valid;
  }

  void reset() {
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

  prvt_setValueForValueHolderElement(v) {
    attributes["value"] = v;
    v == null ? v = "" : v = v.toString();
    this.value_holder_element.value = v;
    if(this.value_holder_element is TextAreaElement)
      this.value_holder_element.text = v;
  }

  void prvt_updateValueFromDom() {
    this.updateAttributes({ "$value_property" : (value_holder_element.value == "" ? null : value_holder_element.value)});
  }

}
