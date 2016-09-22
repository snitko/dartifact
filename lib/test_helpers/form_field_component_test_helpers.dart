part of nest_ui;

HtmlElement createFormField(class_name, { input_el: null, roles: null, value: null, and: null }) {

  if(input_el == null)
    input_el = new InputElement();

  return createDomEl(class_name, roles: roles, and: (el) {

    if(input_el is TextAreaElement) {
      input_el = createDomEl("", el: input_el, part: "value_holder", attr_properties: "name:name");
      input_el.value = value;
    }
    else
      input_el = createDomEl("", el: input_el, part: "value_holder", attr_properties: "name:name", attrs: { "value" : value });

    return [
      createDomEl("", part: "input", attr_properties: "disabled:data-disabled, max_length:data-max-length"),
      input_el
    ];
  });
}
