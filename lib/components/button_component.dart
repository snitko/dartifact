part of dartifact;

class ButtonComponent extends Component {

  final List attribute_names = ["caption", "disabled", "lockable"];
        List native_events   = ["!click"];
        List event_lock_for  = ["click"];

  Map default_attribute_values = { "lockable" : true, "disabled" : false };

  List behaviors = [ButtonComponentBehaviors];

  ButtonComponent() {
    event_handlers.add(event: 'click', role: #self, handler: (self,event) {
      if(self.lockable == true)
        self.behave('lock');
    });

    this.attribute_callbacks["disabled"] = (attr_name,self) {
      if(self.disabled)
        this.behave("disable");
      else
        this.behave("enable");
    };
  }


  @override void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes(attrs: ["lockable", "disabled"], invoke_callbacks: true);
    if(this.lockable == false) {
      event_lock_for.remove("click");
    }
  }

}
