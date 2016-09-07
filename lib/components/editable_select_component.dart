part of nest_ui;

class EditableSelectComponent extends SelectComponent {

  List attribute_names = ["display_value", "input_value", "disabled", "name", "fetch_url", "allow_custom_value", "query_param_name"];

  List native_events   = ["arrow.click", "option.click", "!input.keyup", "!input.keydown", "!input.change", "!input.blur"];
  List behaviors       = [SelectComponentBehaviors, EditableSelectComponentBehaviors];

  static const keypress_stack_timeout = 0.5;
  bool fetching_options               = false;

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

    event_handlers.addForRole("self.input", {
      "keyup": (self,event) {

        switch(event.keyCode) {
          case KeyCode.ESC:
            self.prvt_clearCustomValue(true);
            return;
          case KeyCode.ENTER:
            self.prvt_clearCustomValue();
            return;
          case KeyCode.UP:
            return;
          case KeyCode.DOWN:
            return;
        }


        if(event.target.value.length > 0)
          self.prvt_tryPrepareOptions();
        else {
          self.input_value = null;
          self.focused_option = null;
          self.behave("hideNoOptionsFound");
          self.behave("close");
          self.opened = false;
        }
      },
      
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
      //"change"  : (self,event) => self.prvt_prepareOptions()
    });

    // Instead of catchig a click on any part of the select component,
    // we're only catching it on arrow, because the rest of it is actually an input field.
    event_handlers.add(event: 'click', role: 'self.arrow', handler: (self,event) {
      if(self.opened)
        self.prvt_clearCustomValue();
      else {
        self.behave('open');
        self.opened = true;
      }
    });

    attribute_callbacks["input_value"] = (attr_name, self) {
      this.dom_element.querySelector("[data-component-part=\"input\"]").value = self.input_value;
    };

  }

  get current_input_value => this.dom_element.querySelector("[data-component-part=\"input\"]").value;

  /** Determines whether we allow custom options to be set as the value of the select
    * when we type something in, but no matches were fetched.
    */
  bool allow_custom_options = false;

  void afterInitialize() {
    super.afterInitialize();

    updatePropertiesFromNodes(attrs: ["fetch_url", "allow_custom_value"], invoke_callbacks: false);

    if(this.allow_custom_value == null)
      this.allow_custom_value = false;

    if(this.query_param_name == null)
      this.query_param_name = "q";

    this.original_options = options;
    _listenToOptionClickEvents();

  }

  /** Looks at how much time has passed since the last keystroke. If not much,
    * let's wait a bit more, maybe user is still typing. If enough time passed,
    * let's start fetching options from the remote server / filtering.
    */
  void prvt_tryPrepareOptions() {
    keypress_stack_last_updated = new DateTime.now().millisecondsSinceEpoch;
    new Timer(new Duration(seconds: 0.5), () {
      var now = new DateTime.now().millisecondsSinceEpoch;
      if((now - this.keypress_stack_last_updated >= keypress_stack_timeout*1000) && !this.fetching_options)
        prvt_prepareOptions();
    });
  }

  /** Decides between fetching an option from a remote URL (if fetch_url is set)
    * or just filtering them out of existing pre-loaded ones.
    * Once finished, opens the select box options.
    */
  void prvt_prepareOptions() {

    if(this.fetch_url == null)
      prvt_filterOptions();
    else
      prvt_fetchOptions();

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
  void prvt_filterOptions() {
    this.options = new LinkedHashMap.from(original_options);
    this.original_options.forEach((k,v) {
      if(!k.toLowerCase().startsWith(this.current_input_value.toLowerCase()))
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
  void prvt_fetchOptions() {
    var request_url_with_params = this.fetch_url;
    if(!request_url_with_params.contains("?"))
      request_url_with_params = request_url_with_params + "?";
    request_url_with_params   = request_url_with_params + "q=${this.current_input_value}";

    this.fetching_options = true;
    this.behave('showAjaxIndicator');
    HttpRequest.getString(request_url_with_params)
    .then((String response) {
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
  prvt_clearCustomValue([force=false]) {
    if((!this.options.containsKey(this.input_value) && this.allow_custom_value == false) || force) {
      this.input_value = this.input_value;
    }
    this.behave('close');
    this.opened = false;
  }

  /** This methd is called not once, but every time we fetch new options from the server,
    * because the newly added option elements are not being monitored by the previously
    * created listener.
   */
  _listenToOptionClickEvents() {
    this.event_handlers.remove(event: 'click', role: 'self.option');
    this.event_handlers.add(event: 'click', role: 'self.option', handler: (self,event) {
      var t = event.target;
      setValueByInputValue(t.getAttribute('data-option-value'));
      this.behave('close');
      this.opened = false;
    });
    this.reCreateNativeEventListeners();
  }

  @override
  void externalClickCallback() {
    super.externalClickCallback();
    prvt_clearCustomValue();
  }

}
