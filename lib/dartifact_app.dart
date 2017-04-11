part of dartifact;

class DartifactApp {

  RootComponent root_component;

  DartifactApp({root_element_selector: "body", app_library: ''}) {
    Component.app_library = app_library;
    root_component = new RootComponent();
    root_component.dom_element = querySelector(root_element_selector);
    root_component.initChildComponents();
  }

}
