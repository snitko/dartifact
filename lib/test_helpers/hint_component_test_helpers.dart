part of nest_ui;

HtmlElement createHintElement({ roles: null, and: null, attr_properties: null }) {

  if(attr_properties == null)
    attr_properties = [
     "anchor:data-anchor",
     "open_events:data-open-events",
     "force_open_events:data-force-open-events",
     "autodisplay_delay:data-autodisplay-delay",
     "autohide_delay:data-autohide-delay",
     "display_times_limit:data-display-times-limit",
     "keep_open_when_hover:data-keep-open-when-hover",
     "hint_id:data-hint-id"
    ].join(",");

  return createDomEl("HintComponent", roles: roles, attr_properties: attr_properties, and: (el) {
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
