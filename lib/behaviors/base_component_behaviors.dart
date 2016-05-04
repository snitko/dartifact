part of nest_ui;

class BaseComponentBehaviors {

  Component component;

  BaseComponentBehaviors(this.component) {}

  // Show-hide behaviors
  //
  hide() => this.dom_element.style.display="none";
  show() => this.dom_element.style.display="";
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

  _toggle(behaviors, condition) {
    if(condition)
      behaviors[0]();
    else
      behaviors[1]();
  }

  get dom_element => this.component.dom_element;

}
