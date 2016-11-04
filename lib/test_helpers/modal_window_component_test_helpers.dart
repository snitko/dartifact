part of nest_ui;

HtmlElement createModalWindowElement({ roles: null, and: null, attr_properties: null, attrs: null }) {

  if(attr_properties == null)
    attr_properties = [
     "close_on_escape:data-close-on-escape",
     "close_on_background_click:data-close-on-background-click",
     "show_close_button:data-show-close-button",
    ].join(",");

  return createDomEl("ModalWindowComponent", attrs: attrs, attr_properties: attr_properties, roles: roles, and: (el) {
    return[
      createDomEl("", part: "background"),
      createDomEl("", part: "content"),
      createDomEl("", part: "close")
    ];
  });

}

Component createModalWindowComponent({ content: "hello world", attrs: null, root: null}) {

  if(attrs == null)
    attrs = {};

  var mw = new ModalWindowComponent("hello world", attrs);

  mw.ignore_misbehavior = false;
  var behaviors = new MockModalWindowComponentBehaviors();
  mw.behavior_instances = [behaviors];
  root.addChild(mw);

  return mw;

}
