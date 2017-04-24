part of dartifact;

class RootComponent extends Component {

  List native_events = ["!${Component.click_event}"];
  static RootComponent instance;

  RootComponent() : super() {

    event_handlers.add(event: Component.click_event, role: #self, handler: (self, event) {
      var attrs = event.target.attributes.keys;
      self.applyToChildren('externalClickCallback', null, #recursive, (child) {
        // Prevents calling the method if component contains the click target AND
        // the component doesn't have children, that is we're dealing with the lowest
        // component in the hierarchy.
        return !(child.prvt_hasNode(event.target));
      });
    });

    RootComponent.instance = this;

  }

  @override void _loadI18n() {
    Component.i18n["RootComponent"] = new I18n();
  }

}
