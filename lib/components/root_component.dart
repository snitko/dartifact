part of nest_ui;

class RootComponent extends Component {

  List native_events  = ["!click"];

  RootComponent() : super() {

    event_handlers.add(event: 'click', role: #self, handler: (self, event) {
      var attrs = event.target.attributes.keys;
      self.applyToChildren('externalClickCallback', null, #recursive, (child) {
        // Prevents calling the method if component contains the click target AND
        // the component doesn't have children, that is we're dealing with the lowest
        // component in the hierarchy.
        return !(child.prvt_hasNode(event.target) && child.children.length == 0);
      });
    });

  }



}

