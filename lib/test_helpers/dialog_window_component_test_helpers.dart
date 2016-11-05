part of nest_ui;

HtmlElement createDialogWindowElement({ roles: null, and: null, attr_properties: null, attrs: null }) {

  return createDomEl("DialogWindowComponent", attrs: attrs, attr_properties: attr_properties, roles: roles, and: (el) {
    return[
      createDomEl("", part: "background"),
      createDomEl("", part: "content"),
      createDomEl("", part: "button_container")
    ];
  });

}

Component createDialogWindowComponent({ content: "hello world", attrs: null, mock_behaviors: true}) {

  if(attrs == null)
    attrs = {};

  var mw = new DialogWindowComponent("hello world", attrs);

  if(mock_behaviors) {
    mw.ignore_misbehavior = false;
    var behaviors = new MockModalWindowComponentBehaviors();
    mw.behavior_instances = [behaviors];
  }

  return mw;

}
