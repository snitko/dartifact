part of nest_ui;

class ModalWindowComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  ModalWindowComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  @override Future show() {
  }

  @override Future hide() {
  }

  hideCloseButton() {
    this.component.findPart("close").remove();
  }

}
