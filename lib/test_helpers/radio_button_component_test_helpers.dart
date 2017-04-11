part of dartifact;

HtmlElement createRadioButtonElement({ roles: null, and: null, options: null, attr_properties: null }) {

  if(options == null)
    throw("Please provide options for the RadioButtonInputElement! Use the `options` named argument.");

  return createDomEl("RadioButtonComponent", roles: roles, attr_properties: attr_properties, and: (el) {
    var option_els = [];
    options.forEach((o) {
      option_els.add(createDomEl("", el: new RadioButtonInputElement(), part: "option", attrs: { "id": "my_radio", "value": o }));
    });
    return option_els;
  });
}

Component createRadioButtonComponent({ roles: null, options: null, value: null }) {

  if(options == null)
    options = ["value1", "value2", "value3"];

  var el = createRadioButtonElement(roles: roles, options: options, attr_properties: "value:value");
  var component = createComponent("RadioButtonComponent", el: el);

  return component;
}
