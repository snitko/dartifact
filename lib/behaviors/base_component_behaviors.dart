part of nest_ui;

class BaseComponentBehaviors {

  Component       component;
  PositionManager pos;
  Animator        animator;
  String          _display_value;
  int             show_hide_animation_speed = 500;

  BaseComponentBehaviors(this.component) {
    this.pos      = new PositionManager();
    this.animator = new Animator();
  }

  // Show-hide behaviors
  //
  hide() => this.dom_element.style.display="none";

  show() {

    this.dom_element.style.display = display_value;
  }

  toggleDisplay() => _toggle(
    [show, hide],
    this.dom_element.style.display == 'none'
  );

  // Lock-unlock behaviors
  //
  lock()       => this.dom_element.classes.add("locked");
  unlock()     => this.dom_element.classes.remove("locked");
  toggleLock() => this.dom_element.classes.toggle("locked");

  // Enable-disable behaviors
  //
  disable() {
    this.dom_element.classes.add('disabled');
    this.dom_element.setAttribute('disabled', 'disabled');
  }
  enable() {
    this.dom_element.classes.remove('disabled');
    this.dom_element.attributes.remove('disabled');
  }
  toggleDisable() => _toggle([enable, disable], this.dom_element.classes.contains('disabled'));

  /** Sometimes, we need to display an element with "display: [type];" to calculate its
    * dimensions, but actually keep it hidden. This is exactly what this method does. */
  displayHidden() {
    this.dom_element.style.opacity = "0";
    this.dom_element.style.display = this.display_value;
  }

  _toggle(behaviors, condition) {
    if(condition)
      behaviors[0]();
    else
      behaviors[1]();
  }

  prvt_switchBlockVisibilityIfExists(selector, switch_to, { display: "block" }) {
    var b = this.dom_element.querySelector(selector);
    if(b != null) {
      if(switch_to == #show)
        b.style.display = display;
      else
        b.style.display = "none";
    }
  }

  get dom_element => this.component.dom_element;

  get display_value {
    if(_display_value != null)
      return _display_value;
    _display_value = this.dom_element.attributes["data-component-display-value"];
    if(_display_value == null)
      _display_value = 'block';
    return _display_value;
  }

}
