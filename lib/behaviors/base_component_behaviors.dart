part of nest_ui;

class BaseComponentBehaviors {

  Component component;

  BaseComponentBehaviors() {}

  hide() {
    this.component.dom_element.style..display="none";
  }
  show() => this.component.dom_element.style..display="";

}
