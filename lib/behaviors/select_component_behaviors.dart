part of nest_ui;

class SelectComponentBehaviors extends BaseComponentBehaviors {

  Component   component;
  HtmlElement options_container;
  HtmlElement selectbox;
  int         scroll_pos_bottom = 0;

  SelectComponentBehaviors(Component c) : super(c) {
    this.component = c;
    this.options_container = this.dom_element.querySelector('[data-component-part="options_container"');
    this.selectbox         = this.dom_element.querySelector('[data-component-part="selectbox"');
  }

  toggle() {
    if(this.options_container.style.display == 'none')
      open();
    else
      close();
  }

  open() {
    scroll_pos_bottom = this.component.lines_to_show-1;
    this.selectbox.classes.add("open");
    this.options_container.style.minWidth = "${pos.getDimensions(this.selectbox)['x'] - 2}px";
    this.options_container.style.display = 'block';
    _applyLinesToShow();
  }

  close() {
    this.selectbox.classes.remove("open");
    this.options_container.style.display = 'none';
    _removeFocusFromOptions();
  }

  focusCurrentOption() {
    _removeFocusFromOptions();
    var current_option = this.options_container.querySelector("[data-option-value=\"${this.component.focused_option}\"");
    current_option.classes.add("focused");
    _scroll();
  }

  externalClickResponse() {
    close();
  }

  _removeFocusFromOptions() {
    this.options_container.querySelectorAll('.option').forEach((el) => el.classes.remove("focused"));
  }

  _applyLinesToShow() {
    var opt_els = this.options_container.querySelectorAll('.option');
    if(opt_els.isEmpty)
      return;
    var option_height = pos.getDimensions(opt_els[0])['y'];
    if(this.component.lines_to_show > opt_els.length)
      this.options_container.style.height = "${option_height*opt_els.length}px";
    else
      this.options_container.style.height = "${option_height*this.component.lines_to_show}px";
  }
  
  _scroll() {
    var option_height = pos.getDimensions(this.options_container.querySelector('[data-component-part="option"]'))['y'];
    doScroll() => this.options_container.scrollTop = option_height.toInt()*this.component.focused_option_id;
    if(this.scroll_pos_bottom < this.component.focused_option_id) {
      this.scroll_pos_bottom += 1;
      doScroll();
    } else if(this.scroll_pos_bottom-this.component.lines_to_show+1 > this.component.focused_option_id) {
      this.scroll_pos_bottom -= 1;
      doScroll();
    }
  }

}

