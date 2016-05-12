part of nest_ui;

class FormComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  FormComponentBehaviors(c) : super(c) {
    this.component = c;
  }

  showErrors() {
    this.dom_element.classes.add('errors');

    this.dom_element.querySelector('[data-component-property=validation_errors_summary]').style.display = '';
  }

  hideErrors() {
    this.dom_element.classes.remove('errors');
    this.dom_element.querySelector('[data-component-property=validation_errors_summary]').style.display = 'none';
  }

}
