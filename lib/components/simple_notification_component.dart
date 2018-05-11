part of dartifact;

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
  *   * `container_role` - All notifications will appear in a special DOM element called notifications container,
  *      which is a DOM element for the component identified by `container_role` property and used,
  *      which must be found in children of RootComponent.
  *   
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

  final List attribute_names = ["message", "autohide_delay", "permanent", "message_id", "never_show_again", "container_role", "message_type", "ignore_duplicates"];
  List native_events   = ["close.${Component.click_event}", "message.${Component.click_event}"];
  Map default_attribute_values = {
    "container_role": "simple_notifications_container",
    "permanent": false,   // will not allow this notification to be closed
    "autohide_delay": 10, // will hide the notification
    "message_type": "neutral", // adds css class "message-type-neutral"
    "never_show_again": false, // saves a cookie if true indicating that we shouldn't display the message next time, message_id is required in this case
    "ignore_duplicates": true  // if set to false, allows duplicate notifications to be displayed in the same container
  };

  Future autohide_future;

  List behaviors = [SimpleNotificationComponentBehaviors];
  bool visible   = false;
  Component container;

  SimpleNotificationComponent([attrs=null]) {

    var on_demand = false;
    if(attrs != null) {
      updateAttributes(attrs);
      on_demand = true;
    }
      
    event_handlers.add(event: Component.click_event, role: "self.close", handler: (self, event) => self.hide());
    if(on_demand) afterInitialize();

  }

  @override void afterInitialize() {

    if(this.dom_element == null)
      initDomElementFromTemplate();

    super.afterInitialize();
    updatePropertiesFromNodes();

    if(this.permanent == true)
      this.behave("hideCloseButton");

    var container = RootComponent.instance.findFirstChildByRole("simple_notifications_container");
    //************************************************************************************
    // An explanation is needed for this piece of code. It may seem odd, why don't we just
    // use a regular addChild() method on container? The problem is that `addChild()` tries to
    // makes use of parent setter which leads to stack overflow if the parent is already set
    // (as would be the case with notifications alredy loaded into DOM and not created on deamand).
    //
    // And so, we have to manually add this component as a child to container, then manually append its
    // DOM element to the container's DOM element and then manually set `this.parent` to container.
    //
    // All this is done for the sake of giving users of this class freedom to either create
    // notifications on demand from code or include them into DOM and let dartifact parse and create
    // notifications for you.
    container.children.add(this);
    this.parent = container;
    container.dom_element.append(this.dom_element);
    //************************************************************************************

    show();

  }

  /** Before actually displaying the notification, this method checks whether there are duplicates
   * of the notification in the specified container. It also launches autohide() if applicable.
   */
  void show() {

    // Don't show notification if `never_show_again` is true, `message_id` is passed and a cookie exists
    if(this.never_show_again && (this.message_id != null) && cookie.get("message_${this.message_id}_never_show_again") == "1")
      return;

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
      if(this.never_show_again && (this.message_id != null))
        cookie.set("message_${message_id}_never_show_again", "1", expires: 10000, path: '/', domain: window.location.hostname);
    }
  }

}
