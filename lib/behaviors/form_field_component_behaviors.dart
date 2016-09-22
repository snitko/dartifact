part of nest_ui;

class FormFieldComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  FormFieldComponentBehaviors(c) : super(c) {
    this.component = c;
  }

  showErrors() {
    this.dom_element.classes.add('errors');
    if(this.validation_errors_summary_element != null)
      this.validation_errors_summary_element.style.display = 'block';
  }

  hideErrors() {
    this.dom_element.classes.remove('errors');
    if(this.validation_errors_summary_element != null)
      this.validation_errors_summary_element.style.display = 'none';
  }

  get validation_errors_summary_element {
    return this.component.firstDomDescendantOrSelfWithAttr(
      this.dom_element, attr_name: 'data-component-property', attr_value: 'validation_errors_summary'
    );
  }

}
