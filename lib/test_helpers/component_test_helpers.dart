part of nest_ui;

Component new_instance_of_component(class_name) {
  var c = new_instance_of(class_name, [], Component.app_library);
  if(c == null)
    c = new_instance_of(class_name, [], "");
  return c;
}

Component createComponent(class_name, { and: null, el: null, roles: "", part: "", property: "", attr_properties: ""}) {

  if(el == null)
    el = new DivElement();

  var c = new_instance_of_component(class_name);
  el.attributes["data-component-class"]    = class_name;
  el.attributes["data-component-roles"]    = roles;
  el.attributes["data-component-part"]     = part;
  el.attributes["data-component-property"] = property;
  el.attributes["data-component-attribute-properties"] = attr_properties;
  el.attributes.keys.forEach((k) {
    if(el.attributes[k] == "")
      el.attributes.remove(k);
  });

  if(and != null) {

    var children = and(c);

    // First, add all HtmlElements
    children.forEach((child) {
      if(child is HtmlElement)
        el.append(child);
    });

    c.dom_element = el;

    // Initialize child Components
    c.initChildComponents();

    // Then add child Components that were created manually
    children.forEach((child) {
      if(child is Component)
        c.addChild(child);
    });
  } else {
    c.dom_element = el;
  }
  c.afterInitialize();
  return c;
}

HtmlElement createDomEl(class_name, { and: null, el: null, roles: "", part: "", property: "", attr_properties: "", attrs: null}) {

  if(el == null)
    el = new DivElement();
  if(attrs == null)
    attrs = {};
  
  el.attributes["data-component-class"]                = class_name;
  el.attributes["data-component-roles"]                = roles;
  el.attributes["data-component-part"]                 = part;
  el.attributes["data-component-property"]             = property;
  el.attributes["data-component-attribute-properties"] = attr_properties;
  attrs.forEach((a,v) {
    el.attributes[a] = v.toString();
  });
  el.attributes.keys.forEach((k) {
    if(el.attributes[k] == "")
      el.attributes.remove(k);
  });

  if(and != null) {
    var children = and(el);
    children.forEach((child) {
      el.append(child);
    });
  }

  return el;

}
