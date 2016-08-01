part of nest_ui;

class RootComponent extends Component {

  List native_events  = ["click"];

  RootComponent() : super() {

    event_handlers.add(event: 'click', role: #self, handler: (self, event) {
      var attrs = event.target.attributes.keys;
      self.applyToChildren('behave', ['externalClickResponse'], #recursive, (child) {
        return child.prvt_hasNode(event.target);
      });
    });

  }



}

