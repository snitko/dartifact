part of nest_ui;

class SelectComponent extends Component {

  /* display_value - the one we show to the user,
   * input_value - the one we'd want to send to the server.
   */
  List attribute_names = ["display_value", "input_value", "disabled", "name", "fetch_url"];

  List native_events   = ["selectbox.click", "keypress", "keydown", "option.click"];
  List behaviors       = [SelectComponentBehaviors, FormFieldComponentBehaviors];

  LinkedHashMap options = new LinkedHashMap();
  Map  options_data     = {};
  int  lines_to_show    = 10;
  bool fetching_options = false;

  /** When user presses a key with selectbox focused,
    * we put the character typed by this key into a stack which holds it there for some
    * time - #keypress_stack_timeout - and inserts newly typed chars to the end of it.
    * On each keypress, it finds the first match in the #options map and assigns it
    * as the value. This basically mimicks the default browser behavior for the <select>
    * element.
    */
  String keypress_stack = "";
  int    keypress_stack_last_updated = new DateTime.now().millisecondsSinceEpoch;
  int    keypress_stack_timeout = 1000;

  List special_keys = [32,38,40,27,13];

  /** The value that's picked and about to be set, but awaits user input - specifically a key press */
  String focused_option;

  /** Indicates whether the selectbox is opened. Obviously, this class has nothing to do with visual
    * representation, but this flag is used when deciding what to do with a particular keyboard
    * event, for example - like, we don't want to call `behave('open')` if the selectbox is already opened.
   */
  bool opened = false;

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
    document.onKeyDown.listen((e) => prvt_processKeyDownEvent(e));

    event_handlers.add(event: 'click', role: 'self.selectbox', handler: (self,event) {
      self.behave('toggle');
      _toggleOpenedStatus();
    });
    event_handlers.add(event: 'keypress', role: #self, handler: (self,event) {
      var char = new String.fromCharCodes([event.charCode]);
      updateKeypressStackWithChar(char);
      setValueFromKeypressStack();
    });

  }

  void afterInitialize() {
    super.afterInitialize();
    readOptionsFromDom();
    updatePropertiesFromNodes(attrs: ["input_value", "disabled", "name", "fetch_url"], invoke_callbacks: true);
    if(this.input_value != null)
      this.display_value = options[this.input_value.toString()];
    prvt_listenToOptionClickEvents();
  }

  /** Does what it says. Parses those options from DOM and puts both input values and
    * display values into `options` Map. Note the `options` is actually a LinkedHashMap
    * and element order matters.
    */
  void readOptionsFromDom() {
    var option_els = this.dom_element.querySelectorAll('[data-option-value]');
    for(var el in option_els) {
      var key = el.getAttribute('data-option-value');
      if(key != null)
        options[key] = el.text.trim();
    }
  }

  /** Takes the `options` property and creates html elements for each given option
    * within the options container. All previously existing options are removed from that
    * container.
    */
  updateOptionsInDom() {
    var options_container = this.findPart("options_container");
    this.findAllParts("option").forEach((el) => el.remove());
    this.options.forEach((k,v) {
      var option = this.findPart("option_template").clone(true);
      option.attributes["data-component-part"] = "option";
      option.attributes["data-option-value"]   = k;
      option.text = v;
      options_container.append(option);
    });
  }

  /**************************************************************************
   * The following methods are used to effectively navigate the selectbox
   * with arrow keys. They key handler looks up the keyCode (UP or DOWN) and
   * decides which method to call. Then assignes the returned value
   * to input_value.
   **************************************************************************
   *
   * Takes the next option and returns the input_value of that option.
   * If we're at the end of the list, gets you the first option.
   * If no current option is set (passed) gets your the first option too.
   */
  String getNextValue(String current) {
    var key;
    var opt_keys = options.keys.toList();
    if(opt_keys.isEmpty)
      return null;
    if(current == null)
      return opt_keys.first;
    try {
      key = opt_keys[opt_keys.indexOf(current)+1];
    } catch(RangeError) {
      key = opt_keys.first;
    }
    return key;
  }
  /** Takes the previous option and returns the input_value of that option.
    * If we're at the beginning of the list, gets you the last option.
    * If no current option is set (passed) gets your the last option too.
   */
  String getPrevValue(String current) {
    var key;
    var opt_keys = options.keys.toList();
    if(opt_keys.isEmpty)
      return null;
    if(current == null)
      return opt_keys.last;
    try {
      key = opt_keys[opt_keys.indexOf(current)-1];
    } catch(RangeError) {
      key = opt_keys.last;
    }
    return key;
  }
  void setNextValue() {
    setValueByInputValue(getNextValue(this.input_value));
  }
  void setPrevValue() {
    setValueByInputValue(getPrevValue(this.input_value));
  }
  void setValueByInputValue(ip) {
    if(ip == 'null')
      ip = null;
    this.input_value    = ip;
    this.focused_option = ip;
    this.display_value  = (ip == null ? "" : this.options[ip]);
    this.publishEvent("change", this);
  }

  /** Using `input_value` as a key, simply pulls a new value
    * for `display_value` from the `options` Map.
    */
  void setDisplayValueFromInputValue() {
    this.display_value = this.options[this.input_value.toString()];
    if(this.display_value == null)
      this.display_value = "";
  }
  /**************************************************************************/


  /**************************************************************************
   * The next two methods are used when the selectbox us open and we navigate
   * the items in it without actually setting them. It basically just uses the
   * same mechanism with #getNextValue/#getPrevValue, but instead of assigning
   * those values it just tells select component to display them as focused.
   *
   * Then, when user is ready, he presses ENTER or SPACE and the focused value
   * is actually assigned to input_value.
   **************************************************************************
   */
  void focusNextOption() {
    this.focused_option = getNextValue(this.focused_option);
    this.behave('focusCurrentOption');
  }
  void focusPrevOption() {
    this.focused_option = getPrevValue(this.focused_option);
    this.behave('focusCurrentOption');
  }
  /**************************************************************************/

  /** When user focuses on the select component (for example, by pressing the TAB key)
    * it should then be possible to press letter keys to navigate the options list without
    * opening the selectbox. That's native browser behavior for <select> element and that's
    * what's being emulated here.
    * 
    * Note the use of keypress_stack. If user presses "a" and "b" within 1 second of each other
    * then the stack is going to contain "ab" and we'll be looking for the first option
    * which has display_value that starts with "ab", then setting it as current option
    * (by writing input_value and display_value properties with #setValueByInputValue()).
   */
  void setValueFromKeypressStack() {
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

  /** Everytime a letter key is pressed we need to update the #keypress_stack, which
    * will then be used to set the current value of our select component.
    * We first check whether the last update was less than a second ago and append
    * the new character to the end of the stack in case the user pressed another letter
    * key less than a second ago. If it happened more than a second ago, ignore the previous
    * characters, clear the stack and put this new character into it.
    */
  void updateKeypressStackWithChar(String c) {
    var time = new DateTime.now().millisecondsSinceEpoch;
    if(this.keypress_stack_last_updated < time-keypress_stack_timeout) {
      this.keypress_stack_last_updated = time;
      this.keypress_stack = c;
    } else {
      this.keypress_stack += c;
    }
  }

  /** This method helps us handle what happens when user presses ENTER/SPACE keys.
    * If the selectbox is closed, then just open it. If it's opened, then it means
    * that the user is navigating it with keys and whichever option currently has focus
    * should be set as current. */
  void setFocusedAndToggle() {
    if(this.opened) {
      if(this.focused_option != null)
        setValueByInputValue(this.focused_option);
      this.focused_option = null;
    }
    this.behave('toggle');
    _toggleOpenedStatus();
  }

  /** Makes a request to the remote server at the URL specified in `fetch_url`.
    * Sends along an additional `q` param containing the value entered by user.
    *
    * Expects a json string to be returned containing key/values. However, please note,
    * that for EditableSelectComponent currently only keys are used as values and as options
    * text presented to the user.
    */
  Future fetchOptions() {

    this.fetching_options = true;
    this.behave('showAjaxIndicator');
    return this.ajax_request(this.fetch_url).then((String response) {

      _setOptionsFromFetchedJson(response);
      this.behave('hideAjaxIndicator');

      if(this.options.length > 0) {
        updateOptionsInDom();
        behave("hideNoOptionsFound");
      }
      else {
        this.options = {};
        updateOptionsInDom();
        behave("showNoOptionsFound");
      }

      prvt_listenToOptionClickEvents();
      this.fetching_options = false;
    });
  }

  void updateFetchUrlParams(Map params) {
    params.forEach((k,v) {
      if(v == null || v == "")
        this.fetch_url = this.fetch_url.replaceFirst(new RegExp("$k=.*?(&|\$)"), "");
      else {
        if(this.fetch_url.contains("$k="))
          this.fetch_url = this.fetch_url.replaceFirst(new RegExp("$k=.*?(&|\$)"), "$k=$v&");
        else
          _addFetchUrlParam(k,v);
      }
      if(this.fetch_url.endsWith("&"))
        this.fetch_url = this.fetch_url.replaceFirst(new RegExp(r'&$'), "");
    });
  }

  void externalClickCallback() {
    this.opened = false;
    this.behave("close");
  }

  /** Sometimes we need an index of the option (int), not its input_value */
  get focused_option_id {
    var result = options.keys.toList().indexOf(this.focused_option);
    if(result == -1)
      result = null;
    return result;
  }

  get value => this.input_value;
  ajax_request(url) => HttpRequest.getString(url);

  void _toggleOpenedStatus() {
    this.opened = !this.opened;
  }

  /** The goal of this method is to detect whether the returned JSON contains
    * any additional data and if it does, it will store it in a separate property.
    */
  void _setOptionsFromFetchedJson(json) {
    var parsed_json = {};
    JSON.decode(json).forEach((k,v) {
      if(v is String)
        parsed_json[k] = v;
      else if(v is Map) {
        parsed_json[k] = v["display_value"];
        v.remove("display_value");
        this.options_data[k] = v;
      }
      else
        print("Warning: cannot parse the fetched json!");
    });
    this.options = new LinkedHashMap.from(parsed_json);
  }
  
  /** This methd is called not once, but every time we fetch new options from the server,
    * because the newly added option elements are not being monitored by the previously
    * created listener.
   */
  prvt_listenToOptionClickEvents() {
    this.event_handlers.remove(event: 'click', role: 'self.option');
    this.event_handlers.add(event: 'click', role: 'self.option', handler: (self,event) {
      var t = event.target;
      setValueByInputValue(t.getAttribute('data-option-value'));
      this.behave('close');
      this.opened = false;
    });
    reCreateNativeEventListeners();
  }

  void prvt_processKeyDownEvent(e) {
    if(this.event_locks.contains("keydown") || this.event_locks.contains(#any))
     return;
    if(this.prvt_hasNode(e.target) && this.disabled != 'disabled' && special_keys.contains(e.keyCode)) {
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

  void _addFetchUrlParam(String name, String value) {
    var new_fetch_url = this.fetch_url;
    if(!new_fetch_url.contains("?"))
      new_fetch_url = new_fetch_url + "?";
    if(!new_fetch_url.endsWith("?"))
      new_fetch_url = new_fetch_url + "&";
    this.fetch_url = new_fetch_url + "${name}=${value}";
  }

}
