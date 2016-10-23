part of nest_ui;

class SimpleNotificationComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  SimpleNotificationComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  @override Future show() {
    this.component.container.append(this.dom_element);
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
