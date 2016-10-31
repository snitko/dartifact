part of nest_ui;

Component new_instance_of_component(class_name) {
  var c = new_instance_of(class_name, [], [Component.app_library]);
  if(c == null)
    c = new_instance_of(class_name, [], ["nest_ui"]);
  if(c == null)
    c = new_instance_of(class_name, []);
  return c;
}

/** Creates a new instance of Component.
  * Arguments description:
  *
  *   * `class_name`      - A Component class name an instance of which is to be created.
  *   * `el`              - HtmlElement. Will become the #dom_element of this component. Optional and is created automatically
  *                         if not specified.
  *   * `roles`           - Roles for this component, separated by comma, but passed a single string. Ex.: "button,submit".
  *   * `part`            - In case you decide the #dom_element of the component is also its part (unlikely!).
  *   * `property`        - In case you decide the #dom_element of the component is also a property (unlikely!).
  *   * `attr_properties` - Sometimes properties are stored as #dom_element attributes.
  *   * `attrs`           - Map. Adds any attributes you want to the #dom_element.
  *   * `parent`          - Component. Sets the parent.
  *
  *   * `and`             - a function that must return a List of either Components or HtmlElements (can be mixed) which will become
  *                         children of the component being created with this method.
  *
  */
Component createComponent(String class_name, { and: null, el: null, part: null, roles: "", property: "", attr_properties: "", parent: null}) {

  if(el == null)
    el = createDomEl(class_name, roles: roles, part: part, property: property, attr_properties: attr_properties);

  var c = new_instance_of_component(class_name);
  if(parent != null)
    c.parent = parent;

  if(and != null) {

    var children = and(c);

    // First, add all HtmlElements
    if(children != null) {
      children.forEach((child) {
        if(child is HtmlElement)
          el.append(child);
      });
    }

    c.dom_element = el;

    // Initialize child Components
    c.initChildComponents();

    // Then add child Components that were created manually
    if(children != null) {
      children.forEach((child) {
        if(child is Component) {
          c.addChild(child, initialize: false);
        }
      });
    }

  } else {
    c.dom_element = el;
  }

  c.afterInitialize();
  return c;
}

/** Creates a new HtmlElement that can be parsed by the Component trying to initialize and use it as a #dom_element.
  *  It DOES NOT create an actual Component instance, just the HtmlElement.
  *
  * Arguments description:
  *
  *   * `class_name`      - A Component class name an instance of which is to be created.
  *   * `el`              - HtmlElement. If not specified, a DivElement is used automatically.
  *   * `roles`           - Roles for the component, separated by comma, but passed a single string. Ex.: "button,submit".
  *   * `part`            - When the created element is supposed to be corresponding element for a Component part (`class_name` must be "" then!).
  *   * `property`        - When the created element is supposed to be corresponding element for a Component property (`class_name` must be "" then!).
  *   * `attr_properties` - Sometimes properties are stored as #dom_element attributes.
  *   * `attrs`           - Map. Adds any attributes you want to the #dom_element.
  *   * `and`             - a function that must return a List of HtmlElements which will become children of the
  *                         HtmlElement being created.
  *
  */
HtmlElement createDomEl(String class_name, { and: null, el: null, roles: "", part: "", property: "", attr_properties: "", attrs: null}) {

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
