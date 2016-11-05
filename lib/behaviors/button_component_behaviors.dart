part of nest_ui;

class ButtonComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  Element   ajax_indicator;

  ButtonComponentBehaviors(Component c) : super(c) {
    this.ajax_indicator = querySelector(".ajaxIndicator");
    this.component = c;
  }

  disable() {
    this.dom_element.attributes["disabled"] = "disabled";
  }

  enable() {
    this.dom_element.attributes.remove("disabled");
  }

  lock() {
    if(this.ajax_indicator != null) {
      this.ajax_indicator.style.display = 'block';
      pos.placeBy(this.ajax_indicator, this.dom_element, top: 0.5, left: 0, gravity_top: 0.5, gravity_left: 0.5 );
    }
    super.lock();
  }
}
