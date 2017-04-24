part of dartifact;

class ButtonComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  Element   ajax_indicator;

  ButtonComponentBehaviors(Component c) : super(c) {
    var ai = querySelector(".ajaxIndicator");
    if(ai != null)
      this.ajax_indicator = ai.clone(true);
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
      this.dom_element.parent.insertBefore(this.ajax_indicator, this.dom_element);
      this.ajax_indicator.style.display = 'block';
      this.ajax_indicator.style.position = 'absolute';
      pos.placeBy(this.ajax_indicator, this.dom_element, top: 0.5, left: 0, gravity_top: 0.5, gravity_left: 0.5 );
    }
    super.lock();
  }

  unlock() {
    if(this.ajax_indicator != null)
      this.ajax_indicator.remove();
    this.component.event_locks.remove(Component.click);
    super.unlock();
  }
}
