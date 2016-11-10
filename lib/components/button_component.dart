part of nest_ui;

class ButtonComponent extends Component {

  final List attribute_names = ["caption", "disabled", "lockable", "click_lock"];
        List native_events   = ["!click"];
        List event_lock_for  = ["click"];

  Map default_attribute_values = { "lockable" : true, "click_lock": true };

  List behaviors = [ButtonComponentBehaviors];

  ButtonComponent() {
    event_handlers.add(event: 'click', role: #self, handler: (self,event) {
      if(self.lockable == true)
        self.behave('lock');
    });
  }

  afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["lockable", "click_lock"], invoke_callbacks: true);
    if(this.click_lock == false) {
      event_lock_for.remove("click");
    }
  }

}
