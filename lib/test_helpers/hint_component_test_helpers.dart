part of nest_ui;

HtmlElement createHintElement({ roles: null, and: null, attr_properties: null, attrs: null}) {

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

Component createHintComponent({ roles: null, attrs: null, and: null }) {

  var el = createHintElement(roles: roles);
  var component = createComponent("HintComponent", el: el, and: and);

  return component;
}
