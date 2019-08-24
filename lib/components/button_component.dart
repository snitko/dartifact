part of dartifact;

class ButtonComponent extends Component {

  final List attribute_names = ["caption", "disabled", "lockable"];
        List native_events   = ["!${Component.click_event}", "touchstart"];
        List event_lock_for  = [Component.click_event];

  Map default_attribute_values = { "lockable" : true, "disabled" : false };

  List behaviors = [ButtonComponentBehaviors];

  ButtonComponent() {
    event_handlers.add(event: "click", role: #self, handler: (self,event) {
      if(self.lockable == true) { self.behave('lock'); }
    });

    event_handlers.add(event: "touchend", role: #self, handler: (self,event) {

      var pos = new PositionManager();
      var el_start = pos.getPosition(event.target);
      var el_end   = pos.getDimensions(event.target);
      var point    = event.changedTouches[0].page;

      if(point.x >= el_start["x"] && point.x <= el_end["x"] &&
         point.y >= el_start["y"] && point.y <= el_end["y"] &&
         self.lockable == true) { self.behave('lock'); }
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
      event_lock_for.remove(Component.click_event);
    }
  }

}
