part of nest_ui;

HtmlElement createHintElement({ roles: "hint", and: null, attr_properties: null, attrs: null}) {

  if(attr_properties == null)
    attr_properties = [
     "anchor:data-anchor",
     "show_events:data-show-events",
     "force_show_events:data-force-show-events",
     "autoshow_delay:data-autoshow-delay",
     "autohide_delay:data-autohide-delay",
     "display_limit:data-display-limit",
     "keep_visible_when_hover:data-keep-visible-when-hover",
     "hint_id:data-hint-id"
    ].join(",");

  return createDomEl("HintComponent", roles: roles, attrs: attrs, attr_properties: attr_properties, and: (el) {
    return[
      createDomEl("", part: "close"),
      createDomEl("", part: "close_and_never_show"),
      createDomEl("", part: "content")
    ];
  });

}

Component createHintComponent({ roles: "hint", attrs: null, and: null, parent: null }) {
  var el = createHintElement(roles: roles, attrs: attrs);
  var component = createComponent("HintComponent", el: el, and: and, parent: parent);
  return component;
}

Map<Component> createHintComponentWithParentAndAnchor({attrs: null, anchor_type: "dom_element"}) {

  var anchor;

  if(attrs == null)
    attrs = {};

  var std_attrs = {
    "data-anchor"      : "part:hint_anchor",
    "data-hint-id"     : "test_hint",
    "data-show-events" : "click",
    "data-force-show-events" : "mouseup"
  };
  attrs = mergeMaps(std_attrs, attrs);

  var parent = createComponent("Component", and: (c) {
    var hint_el = createHintElement(attrs: attrs, roles: "hint");
    if(anchor_type == "dom_element")
      anchor = createDomEl(null, part: "hint_anchor");
    else
      anchor = createDomEl("Component", roles: "hint_anchor");
    return [hint_el, anchor];
  });

  return { "hint": parent.findFirstChildByRole("hint"), "parent": parent, "anchor": anchor };

}
