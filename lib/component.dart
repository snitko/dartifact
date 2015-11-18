part of nest_ui;

class Component {

  Component parent;

  Map  behaviors = {};
  Map  events    = {};
  List roles     = [];
  List <Component> children = [];

  Component() {
  }

  addChild(c) {
    this.children.add(c);
  }

  removeChild(child_id, [Symbol id_type=#id]) {
    if(id_type == #id) {
      this.children.removeAt(child_id);
    } else {
      this.children.removeWhere((c) => c.roles.contains(child_id));
    }
  }

}
