part of nest_ui;

class ButtonComponent extends Component {

  final List attribute_names = ["caption", "disabled", "lockable"];
        List native_events   = ["!click"];
        List event_lock_for  = ["click"];

  Map default_attribute_values = { "lockable" : true };

  List behaviors = [ButtonComponentBehaviors];

  ButtonComponent() {
    event_handlers.add(event: 'click', role: #self, handler: (self,event) {
      if(self.lockable == true)
        self.behave('lock');
    });
  }

  @override void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["lockable"], invoke_callbacks: true);
    if(this.lockable == false) {
      event_lock_for.remove("click");
    }
  }

}
