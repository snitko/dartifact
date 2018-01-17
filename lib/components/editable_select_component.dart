part of dartifact;

/** Sometimes you want to allow users to enter values for the select field manually. Perhaps, you want to give them a more explicit way to filter the options.
  * Or, perhaps, you actually want to allow them to enter custom values into the select box. This is what this component is designed to do.
  * It inherits from SelectComponent and the documentation for SelectComponent applies to EditableSelectComponent for the most part too.
  *
  * To understand how this component works, it's simply better to observe it in action, but here's a number of distinct behaviors you'll notice:
  *
  * When user begins to type, the list of options is automatically reduced to the ones that match the typed text.
  * The select box automatically expands after the user types something in to present the filtered list of options.
  * Filtering can occur both by display and input values.
  * Pressing enter saves the custom entered #display_value as #input_value.
  *
  * Properties description:
  *
  *   * `validation_errors_summary`, `name`, `disabled`- inherited from FormFieldComponent.
  *   *
  *   * `display_value`                 - the text that the user sees on the screen inside the element
  *   * `input_value`                   - the value that's sent to the server
  *   * `fetch_url`                     - if set, this is where an ajax request is made to fetch options
  *   * `query_param_name custom value` - when an ajax request is sent to `fetch_url`, this is the name of the param
  *                                       which is used to send the value typed into the field.
  *   * `allow custom value`            - if true, user is allowed to enter custom value into the field
  */
class EditableSelectComponent extends SelectComponent {

  List attribute_names = ["display_value", "input_value", "disabled", "name", "fetch_url", "allow_custom_value", "query_param_name"];
  Map default_attribute_values = { "query_param_name": "q", "allow_custom_value": false, "disabled": false };

  List native_events   = ["arrow.${Component.click_event}", "option.${Component.click_event}", "!display_input.keyup", "!display_input.keydown", "!display_input.change", "!display_input.blur"];
  List behaviors       = [FormFieldComponentBehaviors, SelectComponentBehaviors, EditableSelectComponentBehaviors];

  int keypress_stack_timeout = 500;

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

    event_handlers.remove(event: Component.click_event, role: 'self.selectbox');
    event_handlers.remove(event: 'keypress', role: #self);

    event_handlers.addForRole("self.display_input", {

      "keyup": (self,event) => self.prvt_processInputKeyUpEvent(event),

      "blur":  (self,event) => self.setValueFromManualInput(),

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
    event_handlers.add(event: Component.click_event, role: 'self.arrow', handler: (self,event) {
      if(this.disabled)
        return;
      if(self.opened) {
        self.behave('close');
        self.opened = false;
      } else {
        self.behave('open');
        self.opened = true;
      }
    });

    attribute_callbacks["input_value"] = (attr_name, self) {
      attribute_callbacks_collection['write_property_to_dom']("input_value", self);
      self.display_value = self.options[self.input_value];
      if(self.display_value == null)
        self.display_value = self.input_value;

      // This is a special case of publishing a "change" event. Normally, the change
      // event is published by the code in SelectComponent (parent class), but
      // parent class doesn't know how to set input_value to null or custom_value,
      // thus we need to handle it here.
      if(self.input_value == null || self.input_value == self.display_value)
        self.publishEvent("change", self);
    };

    attribute_callbacks["disabled"] = (attr_name, self) {
      if(self.disabled) {
        this.behave("disable");

        // TODO: have an easy way to update attrs without invoking callbacks!
        this.updateAttributes({ "display_value": "", "input_value": ""}, callback: () => false);
        findPart("display_input").value = "";
        findPart("input").value = "";
      }
      else
        this.behave("enable");
    };

  }

  get current_input_value => findPart("display_input").value;
  get name => findPart("input").name;

  /** Determines whether we allow custom options to be set as the value of the select
    * when we type something in, but no matches were fetched.
    */
  bool allow_custom_options = false;

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["allow_custom_value", "query_param_name"], invoke_callbacks: false);
    this.original_options = options;
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
    * the server and simply want to allow a more flexible SelectComponent
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
    prvt_listenToOptionClickEvents();
  }

  @override Future fetchOptions([String fetch_url = null]) {
    if (fetch_url == null)
      updateFetchUrlParams({ this.query_param_name: this.current_input_value });
    return super.fetchOptions(fetch_url);
  }

  /** Cleares the select box input and sets it to the previous value. Usually
    * called when user presses ESC key or focus is lost on the select element.
    */
  void clearCustomValue() {
    this.display_value = this.display_value;
  }

  /** Sets value after user hits ENTER. If value is in #options, then input_value is set to option's key
    * If not, then intpu_value is set to what the user typed into the field.
    */
  void setValueFromManualInput() {
    if(this.options.containsValue(this.current_input_value)) {
      setValueByInputValue(optionKeyForValue(this.current_input_value));
    } else if(this.allow_custom_value) {
      this.input_value = this.current_input_value;
      this.behave("close");
      this.opened = false;
    } else if(this.current_input_value == "") {
      this.input_value = null;
    }
  }

  void prvt_processInputKeyUpEvent(e) {
    switch(e.keyCode) {
      case KeyCode.ESC:
        setValueFromManualInput();
        return;
      case KeyCode.ENTER:
        setValueFromManualInput();
        return;
      case KeyCode.UP:
        return;
      case KeyCode.DOWN:
        return;
      case KeyCode.BACKSPACE:
        this.focused_option = null;
        setValueFromManualInput();
        return;
    }

    tryPrepareOptions();

    if(e.target.value.length == 0) {
      this.input_value = null;
      this.focused_option = null;
      this.behave("hideNoOptionsFound");
      this.behave("close");
      this.opened = false;
    }

  }

  @override
  void externalClickCallback() {
    super.externalClickCallback();
    if(this.current_input_value != this.display_value)
      clearCustomValue();
  }

  /** Diff from super method --> this.options.keys.contains(this.focused_option)
   *  This prevents from setting input_value if user types in custom value.
   */
  @override
  void setFocusedAndToggle() {
    if(this.opened && this.focused_option != null && this.options.keys.contains(this.focused_option))
      setValueByInputValue(this.focused_option);
    this.behave('toggle');
    _toggleOpenedStatus();
  }

}
