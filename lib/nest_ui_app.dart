part of nest_ui;

class NestUIApp {

  NestUIApp([root_element_selector="body"]) {
    var root_component = new Component();
    root_component.dom_element = querySelector(root_element_selector);
    root_component.initChildComponents();
  }

}
