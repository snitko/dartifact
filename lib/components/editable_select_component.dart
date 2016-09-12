part of nest_ui;

class EditableSelectComponent extends SelectComponent {

  List attribute_names = ["display_value", "input_value", "disabled", "name", "fetch_url", "allow_custom_value", "query_param_name"];
  Map default_attribute_values = { "query_param_name": "q", "allow_custom_value": false, "disabled": false };

  List native_events   = ["arrow.click", "option.click", "!display_input.keyup", "!display_input.keydown", "!display_input.change", "!display_input.blur"];
  List behaviors       = [SelectComponentBehaviors, EditableSelectComponentBehaviors, FormFieldComponentBehaviors];

  int    keypress_stack_timeout = 500;
  bool   fetching_options       = false;


  /** We need this additional property to store ALL loaded properties.
    * When options are filtered, this one stores all options, regardless of whether they
    * were filterd or not.
    */
  LinkedHashMap original_options;

  /** We need to ingore a press of SPACE key, because it is a actually a character
    * used while typing field value, whereas in traditional SelectComponent (from which this
    * class inherits) pressing SPACE opens the select options.
    */
  List special_keys = [38,40,27,13];

  EditableSelectComponent() {
  
    event_handlers.remove(event: 'click', role: 'self.selectbox');
    event_handlers.remove(event: 'click', role: 'self.option');
    event_handlers.remove(event: 'keypress', role: #self);

    event_handlers.addForRole("self.display_input", {

      "keyup": (self,event) => self.prvt_processInputKeyUpEvent(event),
      
      "keydown": (self,event) {
        if(event.keyCode == KeyCode.ENTER)
          event.preventDefault();
      }

      /* I don't want to listen to the change event. First, it creates a loop,
       * when we assign a new input_value and the corresponding html input value is updated.
       * Second, values are supposed to be typed in, not pasted. Don't paste.
       *
       * The commented code is left here for the reference.
       */

      //
      //"change"  : (self,event) => self.prepareOptions()
    });

    // Instead of catchig a click on any part of the select component,
    // we're only catching it on arrow, because the rest of it is actually an input field.
    event_handlers.add(event: 'click', role: 'self.arrow', handler: (self,event) {
      if(this.disabled)
        return;
      if(self.opened)
        self.clearCustomValue();
      else {
        self.behave('open');
        self.opened = true;
      }
    });

    attribute_callbacks["input_value"] = (attr_name, self) {
      attribute_callbacks_collection['write_property_to_dom']("input_value", self);
      self.display_value = self.options[self.input_value];
      if(self.display_value == null)
        self.display_value = self.input_value;
      self.publishEvent("change", self);
    };

    attribute_callbacks["disabled"] = (attr_name, self) {
      if(self.disabled)
        this.behave("disable");
      else
        this.behave("enable");
    };

  }

  get current_input_value => findPart("display_input").value;
  ajax_request(url) => HttpRequest.getString(url);

  /** Determines whether we allow custom options to be set as the value of the select
    * when we type something in, but no matches were fetched.
    */
  bool allow_custom_options = false;

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["fetch_url", "allow_custom_value", "disabled"], invoke_callbacks: false);
    this.original_options = options;
    _listenToOptionClickEvents();
  }

  /** Looks at how much time has passed since the last keystroke. If not much,
    * let's wait a bit more, maybe user is still typing. If enough time passed,
    * let's start fetching options from the remote server / filtering.
    */
  void tryPrepareOptions() {
    if(this.keypress_stack_timeout == 0)
      prepareOptions();
    else {
      keypress_stack_last_updated = new DateTime.now().millisecondsSinceEpoch;
      new Timer(new Duration(milliseconds: this.keypress_stack_timeout), () {
        var now = new DateTime.now().millisecondsSinceEpoch;
        if((now - this.keypress_stack_last_updated >= this.keypress_stack_timeout) && !this.fetching_options)
          prepareOptions();
      });
    }
  }

  /** Decides between fetching an option from a remote URL (if fetch_url is set)
    * or just filtering them out of existing pre-loaded ones.
    * Once finished, opens the select box options.
    */
  void prepareOptions() {

    if(this.fetch_url == null)
      filterOptions();
    else
      fetchOptions();

    if(this.current_input_value.length > 0) {
      behave('open');
      this.opened = true;
    }

  }

  /** Filters options by the value typed in by user.
    * This method is used when we don't want to fetch any options from
    * the server and simply want to allow a more flexibler SelectComponent
    * with the ability to enter value and see explicitly which values match.
    */
  void filterOptions() {
    this.options = new LinkedHashMap.from(original_options);
    this.original_options.forEach((k,v) {
      if(!v.toLowerCase().startsWith(this.current_input_value.toLowerCase()))
        this.options.remove(k);
    });
    if(this.options.isEmpty)
      behave("showNoOptionsFound");
    else
      behave("hideNoOptionsFound");
      
    updateOptionsInDom();
    _listenToOptionClickEvents();
  }

  /** Makes a request to the remote server at the URL specified in `fetch_url`.
    * Sends along an additional `q` param containing the value entered by user.
    *
    * Expects a json string to be returned containing key/values. However, please note,
    * that for EditableSelectComponent currently only keys are used as values and as options
    * text presented to the user.
    */
  void fetchOptions() {

    updateFetchUrlParams({ this.query_param_name : this.current_input_value });

    this.fetching_options = true;
    this.behave('showAjaxIndicator');
    this.ajax_request(this.fetch_url).then((String response) {
      this.options = new LinkedHashMap.from(JSON.decode(response));
      this.behave('hideAjaxIndicator');

      if(this.options.length > 0) {
        updateOptionsInDom();
        behave("hideNoOptionsFound");
      }
      else
        behave("showNoOptionsFound");

      _listenToOptionClickEvents();
      this.fetching_options = false;
    });
  }

  /** Cleares the select box input and sets it to the previous value. Usually
    * called when user presses ESC key or focus is lost on the select element.
    */
  void clearCustomValue([force=false]) {
    if((!this.options.containsKey(this.input_value) && this.allow_custom_value == false) || force) {
      this.input_value = this.input_value;
    } else {
      this.input_value = this.current_input_value;
    }
    this.behave('close');
    this.opened = false;
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

  /** This methd is called not once, but every time we fetch new options from the server,
    * because the newly added option elements are not being monitored by the previously
    * created listener.
   */
  _listenToOptionClickEvents() {
    this.event_handlers.remove(event: 'click', role: 'self.option');
    this.event_handlers.add(event: 'click', role: 'self.option', handler: (self,event) {
      var t = event.target;
      this.input_value = t.getAttribute('data-option-value');
      this.behave('close');
      this.opened = false;
    });
    this.reCreateNativeEventListeners();
  }

  void prvt_processInputKeyUpEvent(e) {
    switch(e.keyCode) {
      case KeyCode.ESC:
        clearCustomValue(true);
        return;
      case KeyCode.ENTER:
        clearCustomValue();
        return;
      case KeyCode.UP:
        return;
      case KeyCode.DOWN:
        return;
    }

    if(e.target.value.length > 0)
      tryPrepareOptions();
    else {
      this.input_value = null;
      this.focused_option = null;
      this.behave("hideNoOptionsFound");
      this.behave("close");
      this.opened = false;
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

  @override
  void externalClickCallback() {
    super.externalClickCallback();
    if(this.current_input_value != this.display_value)
      clearCustomValue();
  }

}
