part of dartifact;

class TestSelectComponentBehaviors extends Mock {
  TestSelectComponentBehaviors(Component c) {}
  noSuchMethod(i) => super.noSuchMethod(i);
}

class TestSelectComponent extends SelectComponent {
  List behaviors = [TestSelectComponentBehaviors];
  var http_request_completer;
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

class TestEditableSelectComponent extends EditableSelectComponent {
  List behaviors = [TestSelectComponentBehaviors];
  int keypress_stack_timeout = 0;
  var http_request_completer;
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

HtmlElement createEditableSelectElement({ roles: null, value: null, and: null, options: null }) {

  if(options == null)
    options = [];

  return createDomEl("TestEditableSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), part: "input", attr_properties: "input_value:value", attrs: { "value" : value }),
      createDomEl("", el: new InputElement(), part: "display_input", property: "display_input"),
      createDomEl("", part: "option_template"),
      createDomEl("", part: "options_container", and: (el) {
        var opt_els = [];
        options.forEach((o) {
          opt_els.add(createDomEl("", part: "option", attrs: { "value": o }));
        });
        return opt_els;
      })
    ];
  });
}

HtmlElement createSelectElement({ roles: null, value: null, and: null, options: null }) {

  if(options == null)
    options = [];

  return createDomEl("TestSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), property: "input_value", attr_properties: "input_value:value", attrs: { "value" : value }),
      createDomEl("", el: new InputElement(), property: "display_value"),
      createDomEl("", part: "option_template"),
      createDomEl("", part: "options_container", and: (el) {
        var opt_els = [];
        options.forEach((o) {
          opt_els.add(createDomEl("", part: "option", attrs: { "value": o }));
        });
        return opt_els;
      })
    ];
  });
}

SelectComponent createSelectComponent({roles: null, options: null}) {
  var el = createSelectElement(roles: roles, options: null);
  return createComponent("TestSelectComponent", el: el, roles: roles);
}

SelectComponent createEditableSelectComponent({roles: null, options: null}) {
  var el = createEditableSelectElement(roles: roles, options: null);
  return createComponent("TestEditableSelectComponent", el: el, roles: roles);
}
