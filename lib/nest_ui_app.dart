part of nest_ui;

class NestUIApp {

  RootComponent root_component;

  NestUIApp({root_element_selector: "body", app_library: ''}) {
    Component.app_library = app_library;
    root_component = new RootComponent();
    root_component.dom_element = querySelector(root_element_selector);
    root_component.initChildComponents();
  }

}
