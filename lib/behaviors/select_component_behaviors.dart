part of nest_ui;

class SelectComponentBehaviors extends BaseComponentBehaviors {

  Component   component;
  HtmlElement options_container;
  HtmlElement selectbox;
  bool        options_container_hidden = true;
  int         scroll_pos_bottom = 0;

  SelectComponentBehaviors(Component c) : super(c) {
    this.component = c;
    this.options_container = this.dom_element.querySelector('[data-component-part="options_container"');
    this.selectbox         = this.dom_element.querySelector('[data-component-part="selectbox"');
  }

  toggle() {
    if(options_container_hidden)
      open();
    else
      close();
  }

  open() {
    scroll_pos_bottom = component.lines_to_show-1;
    selectbox.classes.add("open");
    options_container.style.minWidth = "${pos.getDimensions(selectbox)['x'] - 2}px";
    options_container.style.display = 'block';
    options_container_hidden = false;
    _applyLinesToShow();
  }

  close() {
    selectbox.classes.remove("open");
    options_container.style.display = 'none';
    options_container_hidden = true;
    _removeFocusFromOptions();
  }

  focusCurrentOption() {
    _removeFocusFromOptions();
    var current_option = this.options_container.querySelector(".option[data-option-value=\"${this.component.focused_option}\"");
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
    var opt_els = options_container.querySelectorAll('.option');
    if(opt_els.isEmpty)
      return;
    var option_height = pos.getDimensions(opt_els[0])['y'];
    if(component.lines_to_show > opt_els.length)
      options_container.style.height = "${option_height*opt_els.length}px";
    else
      options_container.style.height = "${option_height*component.lines_to_show}px";
  }
  
  _scroll() {
    var option_height = pos.getDimensions(options_container.querySelector('.option'))['y'];
    doScroll() => options_container.scrollTop = option_height*component.focused_option_id;
    if(scroll_pos_bottom < component.focused_option_id) {
      scroll_pos_bottom += 1;
      doScroll();
    } else if(scroll_pos_bottom-component.lines_to_show+1 > component.focused_option_id) {
      scroll_pos_bottom -= 1;
      doScroll();
    }
  }

}

