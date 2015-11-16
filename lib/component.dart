part of nest_ui;

class Component {

  Component parent;

  Map  behaviors = {};
  Map  events    = {};
  List roles     = [];
  List <Component> children = [];

  Component() {
  }

}
