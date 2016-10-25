part of nest_ui;

abstract class ComponentHeritage {

  /** Very important! This is why the library is called nest_ui. Components are nested.
   *  This method goes through the #dom_element descendants looking for elements which
   *  have data-component-class attribute. If found, a new Component is created with the class
   *  specified in this attribute. Obviously, you should define such a class beforehand and
   *  inherit from Component.
  */
  void initChildComponents({ recursive: true, after_initialize: true }) {

    var elements = _findChildComponentDomElements(this.dom_element);
    elements.forEach((el) {
      var component = new_instance_of(el.getAttribute('data-component-class'), [], [Component.app_library, 'nest_ui']);
      if(component != null) {
        // The order is very important here: we want to first assign dom_element, add
        // component as a child to its parent and init its own children. Only then we
        // call afterInitialize() giving users access to everything we possible can.
        component.dom_element = el;
        this.addChild(component, initialize: false);
        if(recursive)
          component.initChildComponents();
        component.afterInitialize();
      }
    });
    // When all children are initialized, we can safely call this event, to which some components -
    // the ones that require all its children to be initialized before proceeding with their initialization code - are subscribed.
    //
    // The idea is that you can add an event handler into afterInitialize() or the constructor.
    // The event handler, of course, won't be executed until all children are initialized, but it will
    // still be automatic execution/initialization - just slightly delayed.
    this.publishEvent("children_initialized");
  }

  /** Finds immediate children with a specific role */
  List<Component> findChildrenByRole(r) {
    var children_with_roles = [];
    for(var c in children) {
      if(c.roles.contains(r))
        children_with_roles.add(c);
    }
    return children_with_roles;
  }

  /** Finds the first child with a specified role
    * Not this method knows nothing about the order of children in the DOM!
    */
  Component findFirstChildByRole(r) {
    var children = findChildrenByRole(r);
    if(children.length > 0)
      return children[0];
    else
      return null;
  }

  /** Finds all descendants wich satisfy role path.
    * For example, if the current element has a child with role 'form' and
    * this child in turn has a child with role 'submit', then calling
    *
    *   findDescendantsByRole('form.submit')
    *
    * will find that child, but calling
    *
    *   findDescendantsByRole('submit')
    *
    * will NOT and would be equivalent to calling
    *
    *   findChildrenByRole('submit')
    *
    * returning an empty List [].
    *
   */
  List<Component> findDescendantsByRole(r) {
    var role_path  = r.split('.');
    if(role_path.first == "*")
      return findAllDescendantsByRole(role_path.last);
    else
      return findDescendantsByRolePath(role_path);
  }

  List<Component> findDescendantsByRolePath(role_path) {
    var child_role = role_path.removeAt(0);
    var children_with_roles = findChildrenByRole(child_role);

    if(role_path.length > 0) {
      var descendants_with_roles = [];
      for(var c in children_with_roles)
        descendants_with_roles.addAll(c.findDescendantsByRolePath(role_path));
      return descendants_with_roles;
    } else {
      return children_with_roles;
    }
  }

  List<Component> findAllDescendantsByRole(role) {
    var descendants = [];
    this.children.forEach((c) {
      if(c.roles.contains(role))
        descendants.add(c);
      else
        descendants.addAll(c.findAllDescendantsByRole(role));
    });
    return descendants;
  }

  List<Component> findAllDescendantInstancesOf(String class_name) {
    var descendants = [];
    var condition_class_mirror = class_from_string(class_name, [Component.app_library, 'nest_ui']);

    if(condition_class_mirror == null)
      return [];

    this.children.forEach((c) {
      var current_class_mirror = reflect(c).type;
      if(current_class_mirror != null) {
        if(current_class_mirror.isSubclassOf(condition_class_mirror))
          descendants.add(c);
        else
          descendants.addAll(c.findAllDescendantInstancesOf(class_name));
      }
    });
    return descendants;
  }

  /** Calls a specific method on all of it's children. If method doesn't exist on one of the
    * children, ignores and doesn't raise an exception. This method is useful when we want to
    * communicate a common an action to all children, such as when we want to reset() all form
    * elements.
    *
    * The last argument - `condition` - is a function which is passed a child component.
    * The method is not called on any child for which the function returned false.
    * If condition argument is `null` (or nothing passed), then the method is called
    * on all children regardless.
    */
  void applyToChildren(method_name, [args=null, recursive=false, condition=null]) {
    for(var c in children) {
      if((condition == null || (condition != null && condition(c))) && hasMethod(method_name, c))
        callMethod(method_name, c, args);
      // We don't apply condition check to the recursive call. Condition check is the responsibility
      // of each individual component.
      if(recursive != false)
        c.applyToChildren(method_name, args, #recursive, condition);
    }
  }

  /** Reloading HeritageTree#add_child to automatically do the following things
    * when a child component is added:
    *
    * 1. Initialize a dom_element from template
    * 2. Append child's dom_element to the parent's dom_element.
    *
    * Obviously, you might not always want (2), so just redefine #_appendChildDomElement()
    * method in your class to change this behavior.
    */
  void _addChild(Component child, { initialize: true }) {
    _addValidationsToChild(child);
    child.addObservingSubscriber(this);
    // We only do it if this element is clearly not in the DOM.
    if(child.dom_element == null || child.dom_element.parent == null) {
      child.initDomElementFromTemplate();
      _appendChildDomElement(child.dom_element);
    }

    if(initialize)
      child.afterInitialize();
  }

}
