part of nest_ui;

/** The purpose of this component is to display user notifications, such as when a user successfully logs in or incorrectly fills the form.
  * Such notifications usually appear on top of the page and disappear after some time. This component if flexible enough to
  * allow you to tweak for how long a notification should be displayed, whether it should stay there until user leaves the page (permanent),
  * and also tweak the message type (so that you can add CSS code to have different notification colors for different types of messages). 
  *
  * The best part of this component is that you can invoke the notification in two different ways: programmatically, by writing
  * Dart code and initializing the component or by having a DOM element in your DOM. The latter is convenient to automatically
  * display messages on page load and is, probably, the most common way in which this component is going to be used.
  *
  * Properties description:
  *
  *   * `message` - the text that the user sees on the screen inside the element
  *
  *   * `message_type` - This property doesn't affect anything important, but if set, it automatically adds a class
  *   to the .dom_element: class="message-type-${message_type}".
  *   Then in your CSS code you can specify various styles for different types of messages.
  *
  *   * `autohide_delay` - A common practice is to have notification disappear over time.
  *   This property sets the number of seconds before the notification disappears once its displayed.
  *
  *   * `permanent` - If you want to completely disallow closing the notification, you'll need to set the permanent property to true.
  *   Then it becomes impossible to close the notification and even the close part HTML element gets hidden.
  *
  *   * `container_selector` - All notifications will appear in a special DOM element called notifications container.
  *   Normally, you'd want to style it in such a way, so that its position is fixed and it appears somewhere on top.
  *   This property defines a selector by which such a container is identified.
  *
  *   * `ingore_duplicates`  - Most of the time it's a good idea not to show identical notifications twice.
  *   For that reason, the default behavior of SimpleNotificationComponent is to check whether there's
  *   another instance of the same class which is currently visible inside the same notifications container.
  *   The default is `true`, but if set to `false`, two more identical notifications may be shown.
  *
  */
class SimpleNotificationComponent extends Component with AutoShowHide {

  final List attribute_names = ["message", "autohide_delay", "permanent", "container_selector", "message_type", "ignore_duplicates"];
        List native_events   = ["close.click"];
        Map default_attribute_values = {
          "container_name": "#simple_notifications_container",
          "permanent": false,   // will not allow this notification to be closed
          "autohide_delay": 10, // will hide the notification
          "message_type": "neutral", // adds css class "message-type-neutral"
          "ignore_duplicates": true  // if set to false, allows duplicate notifications to be displayed in the same container
        };

  Future autohide_future;

  List behaviors = [SimpleNotificationComponentBehaviors];
  bool visible   = false;
  HtmlElement container;

  SimpleNotificationComponent({ attrs: null }) {
    updateAttributes(attrs);
    this.container = querySelector("#simple_notifications_container");
    event_handlers.add(event: "click", role: "self.close", handler: (self, event) => self.hide());
  }

  @override void afterInitialize() {
    super.afterInitialize();
    updatePropertiesFromNodes();

    if(this.permanent == true)
      this.behave("hideCloseButton");

    this.show();
  }

  /** Before actually displaying the notification, this method checks whether there are duplicates
    * of the notification in the specified container. It also launches autohide() if applicable.
    */
  void show() {

    // Don't do anything if a similar message has been displayed before.
    if(this.ignore_duplicates && this.parent != null) {
      var has_duplicate = false;
      this.root_component.findAllDescendantInstancesOf(getTypeName(this)).forEach((n) {
        if(n.message == this.message && n != this)
          has_duplicate = true;
      });
      if(has_duplicate) {
        this.hide();
        return;
      }
    }

    behave("show");
    this.visible = true;
    autohide();
  }

  /** Hides the notification and removes it from the parent component. */
  void hide() {
    if(this.permanent == null || this.permanent == false) {
      behave("hide");
      this.visible = false;
      this.parent.removeChild(this);
    }
  }

}
