part of nest_ui;

HtmlElement createFormFieldElement(class_name, { input_el: null, roles: null, value: null, and: null }) {

  if(input_el == null)
    input_el = new InputElement();

  var el = createDomEl(class_name, roles: roles, and: (el) {

    if(input_el is TextAreaElement) {
      input_el = createDomEl("", el: input_el, part: "value_holder", attr_properties: "name:name");
      input_el.value = value;
    }
    else
      input_el = createDomEl("", el: input_el, part: "value_holder", attr_properties: "name:name", attrs: { "value" : value });

    var errors_el = createDomEl("", property: "validation_errors_summary");
    errors_el.style.display = "none";
    
    return [
      createDomEl("", part: "input", attr_properties: "disabled:data-disabled, max_length:data-max-length"),
      input_el, errors_el
    ];
  });
  return el;
}

Component createFormFieldComponent({ roles: null, value: null }) {

  var el = createFormFieldElement("FormFieldComponent", value: value, roles: roles);
  var component = createComponent("FormFieldComponent", el: el, roles: roles);

  return component;
}
