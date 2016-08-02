part of nest_ui;

class SelectComponent extends Component {

  List attribute_names = ["display_value", "input_value", "disabled"];
  List native_events   = ["selectbox.click", "keypress", "keydown", "option.click"];
  List behaviors       = [SelectComponentBehaviors];

  SplayTreeMap options = new SplayTreeMap();
  int lines_to_show = 10;

  /** When user presses a key with selectbox focused,
    * we put the character typed by this key into a stack which holds it there for some
    * time - #keypress_stack_timeout - and inserts newly typed chars to the end of it.
    * On each keypress, it finds the first match in the #options map and assigns it
    * as the value. This basically mimicks the default browser behavior for the <select>
    * element.
    */
  String keypress_stack = "";
  int    keypress_stack_last_updated = new DateTime.now().millisecondsSinceEpoch;
  String focused_option;
  bool   opened = false;
  static const keypress_stack_timeout = 1;

  Map attribute_callbacks = {
    'default'  : (attr_name, self) => self.attribute_callbacks_collection['write_property_to_dom'](attr_name, self),
    'disabled' : (attr_name, self) {
      if(self.disabled == 'disabled') {
        self.event_locks.add(#any); 
        self.behave('disable');
      } else {
        self.behave('enable');
        self.event_locks.remove(#any);
      }
    }
  };

  SelectComponent() {

    // Workaround. Dart doesn't catch keydown events on divs, only on document -
    // but, surprise, it corretly sets the target, so we can still get it!
    document.onKeyDown.listen((e) => prvt_processKeyEvent(e));

    event_handlers.add(event: 'click', role: 'self.selectbox', handler: (self,event) {
      self.behave('toggle');
      _toggleOpenedStatus();
    });
    event_handlers.add(event: 'keypress', role: #self, handler: (self,event) {
      var char = new String.fromCharCodes([event.charCode]);
      updateKeypressStackWithChar(char);
      setValueFromKeypressStack();
    });
    event_handlers.add(event: 'click', role: 'self.option', handler: (self,event) {
      var t = event.target;
      this.input_value   = t.getAttribute('data-option-value');
      this.display_value = options[this.input_value];
      self.behave('close');
      _toggleOpenedStatus();
    });

  }

  afterInitialize() {
    super.afterInitialize();
    readOptionsFromDom();
    updatePropertiesFromNodes(attrs: ["input_value", "disabled"], invoke_callbacks: true);
    if(this.input_value != null)
      this.display_value = options[this.input_value];
  }

  readOptionsFromDom() {
    var option_els = this.dom_element.querySelectorAll('[data-component-part="option"]');
    for(var el in option_els)
      options[el.getAttribute('data-option-value')] = el.text.trim();
  }

  getNextValue(String current) {
    if(current == null)
      return options.firstKey();
    var key = options.firstKeyAfter(current);
    if(key == null)
      key = options.firstKey();
    return key;
  }
  getPrevValue(String current) {
    if(current == null)
      return options.lastKey();
    var key = options.lastKeyBefore(current);
    if(key == null)
      key = options.lastKey();
    return key;
  }
  setNextValue() {
    setValueByInputValue(getNextValue(this.input_value));
  }
  setPrevValue() {
    setValueByInputValue(getPrevValue(this.input_value));
  }
  focusNextOption() {
    this.focused_option = getNextValue(this.focused_option);
    this.behave('focusCurrentOption');
  }
  focusPrevOption() {
    this.focused_option = getPrevValue(this.focused_option);
    this.behave('focusCurrentOption');
  }
  
  setValueByInputValue(ip) {
    this.input_value    = ip;
    this.focused_option = ip;
    this.display_value  = this.options[ip];
  }

  setValueFromKeypressStack() {
    var found = false;
    options.forEach((k,v) {
      if(found)
        return;
      if(v.toLowerCase().startsWith(this.keypress_stack.toLowerCase())) {
        this.setValueByInputValue(k);
        found = true;
      }
    });
  }

  updateKeypressStackWithChar(String c) {
    var time = new DateTime.now().millisecondsSinceEpoch;
    if(this.keypress_stack_last_updated < time-(keypress_stack_timeout*1000)) {
      this.keypress_stack_last_updated = time;
      this.keypress_stack = c;
    } else {
      this.keypress_stack += c;
    }
  }

  setFocusedAndToggle() {
    if(this.opened) {
      if(this.focused_option != null)
        setValueByInputValue(this.focused_option);
      this.focused_option = null;
    }
    this.behave('toggle');
    _toggleOpenedStatus();
  }

  _toggleOpenedStatus() {
    this.opened = !this.opened;
  }

  get focused_option_id {
    return options.keys.toList().indexOf(this.focused_option);
  }


  prvt_processKeyEvent(e) {
    if(this.event_locks.contains("keydown") || this.event_locks.contains(#any))
     return;
    if(e.target == this.dom_element && this.disabled != 'disabled' && [32,38,40,27,13].contains(e.keyCode)) {
      switch(e.keyCode) {
        case KeyCode.ESC:
          _toggleOpenedStatus();
          this.behave('close');
          break;
        case KeyCode.UP:
          this.opened ? focusPrevOption() : setPrevValue();
          break;
        case KeyCode.DOWN:
          this.opened ? focusNextOption() : setNextValue();
          break;
        case KeyCode.ENTER:
          this.setFocusedAndToggle();
          break;
        case KeyCode.SPACE:
          this.setFocusedAndToggle();
          break;
      }
      e.preventDefault();
    } 
  }

}
