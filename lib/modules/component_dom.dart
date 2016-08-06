part of nest_ui;

abstract class ComponentDom {

  /** Clones #template and assigns the clone to #dom_element, then sets all the properties */
  void initDomElementFromTemplate() {
    if(this.template != null) {
      this.dom_element = this.template.clone(true);
      this.dom_element.attributes.remove('data-component-template');
      this.dom_element.setAttribute('data-component-class', this.runtimeType.toString());
      attribute_names.forEach((a) => prvt_writePropertyToNode(a));
    }
  }

  /** Finds first DOM descendant with a certain combination of attribute and its value,
   *  or returns the same node if that node has that combination.
   * 
   *  This method is needed when we want to listen to #dom_element's descendant native events
   *  or when a property is changed and we need to change a correspondent descendant node.
   */
  HtmlElement firstDomDescendantOrSelfWithAttr(node, { attr_name: null, attr_value: null }) {
    var elements = allDomDescendantsAndSelfWithAttr(node, attr_name: attr_name, attr_value: attr_value, first_only: true);
    if(elements != null && elements.length > 0)
      return elements[0];
  }

  List<HtmlElement> allDomDescendantsAndSelfWithAttr(node, { attr_name: null, attr_value: null, first_only: false }) {
    var actual_attr_value = node.getAttribute(attr_name);

    if(attr_value is RegExp && actual_attr_value != null && attr_value.hasMatch(actual_attr_value))
      return [node];
    else if(attr_name == null || node.getAttribute(attr_name) == attr_value)
      return [node];
    else if(node.children.length == 0)
      return null;

    List elements = [];
    for(var c in node.children) {
      if(c.getAttribute('data-component-class') == null) {
        var children_elements = allDomDescendantsAndSelfWithAttr(c, attr_name: attr_name, attr_value: attr_value);
        if(children_elements != null)
          elements.addAll(children_elements);
        if(elements.length > 0 && first_only)
          break;
      }
    }

    return elements;
  }

  /** Updates all properties values from their DOM nodes values.
    * If provided with an optional List of property names, updates only
    * properties that are on that List.
    */
  void updatePropertiesFromNodes({ attrs: false, invoke_callbacks: false }) {
    if(attrs == false)
      attrs = this.attribute_names;
    for(var a in attrs) {
      prvt_readPropertyFromNode(a);
      if(invoke_callbacks)
        invokeAttributeCallback(a);
    }
  }

  /** Updates dom element's #text or attribute so it refelects Component's current property value. */
  void prvt_writePropertyToNode(String property_name) {
    if(this.dom_element == null)
      return;
    var property_el = prvt_findPropertyEl(property_name);
    if(property_el != null) {
      var pa = property_el.attributes['data-component-attribute-properties'];
      if(pa == null)
        property_el.text = this.attributes[property_name];
      else {
        var attr_property_name = prvt_getHtmlAttributeNameForProperty(pa, property_name);
        if(this.attributes[property_name] == null)
          property_el.attributes.remove(attr_property_name);
        else
          property_el.setAttribute(attr_property_name, this.attributes[property_name]);
      }
    }
  }

  /** Reads property value from a DOM node, updates Component's object property with the value */
  void prvt_readPropertyFromNode(String property_name) {
    var property_el = prvt_findPropertyEl(property_name);
    if(property_el != null) {
      var pa = property_el.attributes['data-component-attribute-properties'];
      if(pa == null) {
        var s = property_el.text;
        // Ignore whitespace. If you need to preserve whitespace,
        // use attribute-based properties instead.
        s = s.replaceFirst(new RegExp(r"^\s+"), "");
        s = s.replaceFirst(new RegExp(r"\s+$"), "");
        this.attributes[property_name] = s;
      }
      else {
        var attr_property_name = prvt_getHtmlAttributeNameForProperty(pa, property_name);
        this.attributes[property_name] = property_el.getAttribute(attr_property_name);
      }
      if(this.attributes[property_name] is String && this.attributes[property_name].isEmpty)
        this.attributes[property_name] = null;
    }
  }

  /** Finds property node in the DOM */
  HtmlElement prvt_findPropertyEl(String property_name) {
    var property_el = this.firstDomDescendantOrSelfWithAttr(
      this.dom_element,
      attr_name: "data-component-property",
      attr_value: property_name
    );
    if(property_el == null) {
      property_el = this.firstDomDescendantOrSelfWithAttr(
        this.dom_element,
        attr_name: "data-component-attribute-properties",
        // This one finds attribute properties of the format
        // property_name:html_attribute_name_for_the_property
        attr_value: new RegExp('(^|,| +)$property_name:')
      );
    }
    return property_el;
  }

  String prvt_getHtmlAttributeNameForProperty(String attr_list, String property_name) {
    var attr_list_regexp = new RegExp("${property_name}:" r"[a-zA-Z0-9_\-]+");
    return attr_list_regexp.firstMatch(attr_list)[0].split(':')[1];
  }

  /** Finds whether the dom_element's descendants has a particular node
    * or if it itself is this node.
    */
  bool prvt_hasNode(node) {
    if(node == this.dom_element)
      return true;
    for(final descendant in this.dom_element.querySelectorAll("*"))
      if(node == descendant)
        return true;
    return false;
  }

  /** Finds the template HtmlElement in the dom and assigns it to #template */
  void _initTemplate() {
    this.template = querySelector("[data-component-template=${this.runtimeType.toString()}");
  }

  void _assignRolesFromDomElement() {
    var roles_attr = dom_element.getAttribute('data-component-roles');
    if(roles_attr != null)
      this.roles = dom_element.getAttribute('data-component-roles').split(new RegExp(r",\s?"));
  }

  /**  In order to be able to instatiate nested components, we need to find descendants of the #dom_element
    *  which have data-component-class attribute. This method takes care of that.
    */
  List<HtmlElement> _findChildComponentDomElements(node) {
    List component_children = [];
    node.children.forEach((c) {
      if(c.getAttribute('data-component-class') == null)
        component_children.addAll(_findChildComponentDomElements(c));
      else
        component_children.add(c);
    });
    return component_children;
  }

  /** This method defines a default behavior when a new child is added.
    * Makes sense to append child dom_element to the parent's dom_element.
    * Of course, this might not always be desirable, so this method may be
    * redefined in descendant calasses.
    */
  void _appendChildDomElement(HtmlElement el) {
    this.dom_element.append(el);
  }

  /** Defines behavior for removal of the #dom_element
    * Redefine this method to have something fancier (like an animation)
    * for when the #dom_element is removed.
    */
  void _removeDomElement() {
    this.dom_element.remove();
  }

}
