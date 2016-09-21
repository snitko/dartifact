part of nest_ui;

class TestSelectComponent extends SelectComponent {
  var http_request_completer;
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

class TestEditableSelectComponent extends EditableSelectComponent {
  int keypress_stack_timeout = 0;
  var http_request_completer;
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

HtmlElement createEditableSelect({ roles: null, and: null }) {
  return createDomEl("TestEditableSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), part: "display_input", property: "display_input"),
      createDomEl("", el: new InputElement(), part: "input")
    ];
  });
}

HtmlElement createSelect({ roles: null, and: null }) {
  return createDomEl("TestSelectComponent", roles: roles, and: (el) {
    return [
      createDomEl("", el: new InputElement(), property: "input_value", attr_properties: "input_value:value"),
      createDomEl("", el: new InputElement(), property: "display_value")
    ];
  });
}
