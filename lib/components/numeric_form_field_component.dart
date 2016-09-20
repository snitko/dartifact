part of nest_ui;

class NumericFormFieldComponent extends FormFieldComponent {

  List attribute_names = ["validation_errors_summary", "name", "disabled", "max_length"];

  void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["disabled", "name", "max_length"], invoke_callbacks: true);
  }

  @override
  set value(v) {

    if(v is String) {

      var numeric_regexp = new RegExp(r"^(\d|\.)*$");
      if(numeric_regexp.hasMatch(v) && (max_length == null || v.length <= max_length)) {
        if(v.endsWith(".") || v.startsWith("."))
          v = null;
        else if(v != null && v.length > 0)
          v = double.parse(v);
        else
          v = null;
        this.attributes["value"] = v;
        this.publishEvent("change", this);
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

  @override
  void prvt_updateValueFromDom() {
    this.value = value_holder_element.value;
  }

}
