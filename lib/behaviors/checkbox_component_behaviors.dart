part of dartifact;

class CheckboxComponentBehaviors extends BaseComponentBehaviors {
  Component component;

  CheckboxComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  check() {
    this.dom_element.checked = true;
  }

  uncheck() {
    this.dom_element.checked = false;
  }
}
