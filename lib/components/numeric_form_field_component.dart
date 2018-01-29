part of dartifact;

/** Numeric field can only contain digits and a period (.) character.
  * All other characters are automatically erased.
  *
  * Properties description:
  *
  *   * `validation_errors_summary`, `name`, `disabled`- inherited from FormFieldComponent.
  *   *
  *   * `display_value`                 - the text that the user sees on the screen inside the element
  *   * `input_value`                   - the value that's sent to the server
  */
class NumericFormFieldComponent extends FormFieldComponent {

  List attribute_names = ["validation_errors_summary", "name", "disabled", "max_length"];

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["disabled", "name", "max_length"], invoke_callbacks: true);
  }

  /** This method is reloaded (from FormFieldComponent) to make sure
    * we only allow digits and period (.) in to be entered into the field.
    * If a user enters some other character it is immediately erased.
    *
    * Additionally, it makes sure the length of the field does not exceed
    * the value in the #max_length property.
    */
  @override set value(v) {

    if(v is String) {

      var numeric_regexp = new RegExp(r"^(\d|\.)*$");
      if(numeric_regexp.hasMatch(v) && (max_length == null || v.length <= max_length)) {

        // handling the case with two decimal points (let's not allow that)
        var decimal_points_regexp = new RegExp(r"\.");
        if(decimal_points_regexp.allMatches(v).length >= 2) {
          v = this.attributes["value"];
          this.value_holder_element.value = v.toString();
        }

        else if(v.endsWith(".") || v.startsWith(".")) {
          v = null;
        } else if(v != null && v.length > 0) {
          v = double.parse(v);
          this.attributes["value"] = v;
          this.publishEvent("change", this);
        } else {
          v = null;
        }

      } else {
        if(this.value != null)
          this.value_holder_element.value = this.value.toString().replaceFirst(new RegExp(r"\.0$"), "");
        else
          this.value_holder_element.value = "";
      }

    } else if (v is num) {

      this.attributes["value"] = v;
      this.publishEvent("change", this);

    }
  }

  @override void prvt_updateValueFromDom({ event: null }) {
    this.value = value_holder_element.value;
  }

}
