part of dartifact;

class SelectComponentBehaviors extends BaseComponentBehaviors {

  Component   component;
  HtmlElement options_container;
  HtmlElement selectbox;
  int         scroll_pos_bottom = 0;
  HtmlElement null_option_el;

  SelectComponentBehaviors(Component c) : super(c) {
    this.component = c;
    this.options_container = this.component.findPart("options_container");
    this.selectbox         = this.component.findPart("selectbox");
  }

  showAjaxIndicator()  => prvt_switchBlockVisibilityIfExists(".ajaxIndicator", #show, display: "inline");
  hideAjaxIndicator()  => prvt_switchBlockVisibilityIfExists(".ajaxIndicator", #hide);
  showNoOptionsFound() => prvt_switchBlockVisibilityIfExists(".noOptionsFoundMessage", #show);
  hideNoOptionsFound() => prvt_switchBlockVisibilityIfExists(".noOptionsFoundMessage", #hide);

  toggle() {
    if(this.component.opened)
      close();
    else
      open();
  }

  open() {
    scroll_pos_bottom = this.component.lines_to_show-1;
    this.selectbox.classes.add("open");
    this.options_container.style.minWidth = "${pos.getDimensions(this.selectbox)['x'] - 2}px";
    this.options_container.style.display = 'block';
    _applyLinesToShow();
    if(!(isBlank(this.component.input_value))) {
      focusCurrentOption();
      this.component.focused_option = this.component.input_value;
    }
  }

  close() {
    this.selectbox.classes.remove("open");
    this.options_container.style.display = 'none';
    _removeFocusFromOptions();
  }

  focusCurrentOption() {
    _removeFocusFromOptions();
    var current_option = this.options_container.querySelector("[data-option-value=\"${this.component.focused_option}\"]");
    if(current_option != null) {
      current_option.classes.add("focused");
      _scroll();
    }
  }

  hideNoValueOption() {
    this.null_option_el = this.options_container.querySelector("[data-option-value=\"null\"]");
    if(this.null_option_el != null)
      this.null_option_el.remove();
  }
  
  showNoValueOption() {
    if(this.null_option_el != null && this.options_container.querySelector("[data-option-value=\"null\"]") == null && !this.options_container.children.isEmpty)
      this.options_container.insertBefore(this.null_option_el, this.options_container.children.first);
  }

  disable() {
    this.dom_element.attributes["disabled"] = "disabled";
    this.component.event_locks.add(#any);
  }

  enable() {
    this.dom_element.attributes.remove("disabled");
    this.component.event_locks.remove(#any);
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
    var option_height = pos.getDimensions(this.component.findPart("option"))['y'];
    scrollDown() => this.options_container.scrollTop = option_height.toInt()*this.component.focused_option_id;
    scrollUp() => this.options_container.scrollTop   = option_height.toInt()*this.component.focused_option_id-((this.component.lines_to_show-1)*option_height.toInt());
    if(this.scroll_pos_bottom < this.component.focused_option_id) {
      this.scroll_pos_bottom += this.component.lines_to_show;
      scrollDown();
    } else if(this.scroll_pos_bottom-this.component.lines_to_show+1 > this.component.focused_option_id) {
      this.scroll_pos_bottom -= this.component.lines_to_show;
      scrollUp();
    }
  }

}

