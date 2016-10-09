part of nest_ui;

class SimpleNotificationComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  SimpleNotificationComponentBehaviors(Component c) : super(c) {
  }

  @override show() {
  }

  @override hide() {
  }

  void adjustPosition(HtmlElement) {
    // Checks if there's any simple_notification above it
    //  If YES:
    //    Moves itself closer up to the notification directly preceding it.
    //  IF NO:
    //    Check whether there's enough empty space above to move up, if YES - move up.
  }

}
