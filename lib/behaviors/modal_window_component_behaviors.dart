part of dartifact;

class ModalWindowComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  ModalWindowComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  @override Future show() {
    return this.animator.show(this.dom_element, this.show_hide_animation_speed);
  }

  @override Future hide() {
    var f = this.animator.hide(this.dom_element, this.show_hide_animation_speed);
    f.then((r) => this.dom_element.remove());
    return f;
  }

  hideCloseButton() {
    this.component.findPart("close").remove();
  }

}
