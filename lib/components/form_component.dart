part of nest_ui;

class FormComponent extends Component {

  List   native_events = ["value_holder.change", "change"];
  String value_property = 'value';
  Map    attribute_names = ["validation_errors_summary"];

  FormComponent() {

    attribute_names.add(value_property);

    event_handlers.add_for_event('change', {
        #self:               (self, p) => self.prvt_updateValueFromDom(),
        'self.value_holder': (self, p) => self.prvt_updateValueFromDom()
      }
    );

  }

  prvt_updateValueFromDom() {
    var value_holder = this.dom_element.querySelector('[data-component-part=value_holder]');
    if(value_holder == null)
      value_holder = this.dom_element;
    this.updateAttributes({ "$value_property" : value_holder.value });
  }


}
