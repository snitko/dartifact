part of nest_ui;

class ButtonComponent extends Component {

  final List attribute_names = ["caption", "disabled"];
        List native_events   = ["!click"];
        List event_lock_for  = ["click"];

  List behaviors = [ButtonComponentBehaviors];

  ButtonComponent() {
    event_handlers.add(event: 'click', role: #self, handler: (self,event) => self.behave('lock'));
  }

}
