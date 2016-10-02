part of nest_ui;

class TestSelectComponentBehaviors extends Mock {
  TestSelectComponentBehaviors(Component c) {}
  noSuchMethod(i) => super.noSuchMethod(i);
}

class TestSelectComponent extends SelectComponent {
  List behaviors = [TestEditableSelectComponentBehaviors];
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

HtmlElement createEditableSelectElement({ roles: null, value: null, and: null }) {
  return createDomEl("TestEditableSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), part: "input", attr_properties: "input_value:value", attrs: { "value" : value }),
      createDomEl("", el: new InputElement(), part: "display_input", property: "display_input"),
      createDomEl("", part: "option_template"),
      createDomEl("", part: "options_container")
    ];
  });
}

HtmlElement createSelectElement({ roles: null, value: null, and: null }) {
  return createDomEl("TestSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), property: "input_value", attr_properties: "input_value:value", attrs: { "value" : value }),
      createDomEl("", el: new InputElement(), property: "display_value"),
      createDomEl("", part: "option_template"),
      createDomEl("", part: "options_container")
    ];
  });
}
