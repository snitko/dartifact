part of dartifact;

/** This component is almost like ModalWindowComponent with one major difference:
  * the `#completed` property returns a Future which may later be used
  * to run code upon the the DialogWindow closure.
  *
  * Additionally, it automatically adds buttons which all close the window,
  * but return different values from the Future. That way, you can determine
  * which button was pressed and run the aprropriate code.
  *
  * Example.
  * A dialog window that asks to confirm the removal of a user's blog post would
  * have two buttons: "Yes" and "No". Clicking the first one, makes
  * the DialogWindow Future complete with `true`, while clicking the second
  * one makes it complete with `false`.
  *
  * Which buttons return what is determined by the `#options` property -
  * read documentation on it to understand how to have the buttons you want to.
  * You can pass a value for this property as a second argument to the constructor.
  *
  * The options that were passed as a second argument to the ModalWindowComponent's
  * constructor are no longer available and are set to sane defaults - a dialog window
  * is a little less flexible in terms of how you can close it!
  */
class DialogWindowComponent extends ModalWindowComponent {

  /** This defines Button roles and captions and the values the window's Future
    * returns when one of the buttons is pressed.
    *
    * The keys in the Map are button roles, the inside of the nested map
    * is sort of self-descriptive. Perhaps "type" should be explained:
    * it basically adds the right kind of html class to the button.
    */
  Map options = { "ok" : { "caption": "OK", "type" : null, "value": true}};

  DialogWindowComponent(content, [opts=null]) : super(content) {

    // Some sane settings for the Dialog window that are not supposed to be changed:
    // (at least for now) - user shouldn't be able to close it in any other way,
    // than by clicking the presented option buttons.
    this.close_on_escape           = false;
    this.close_on_background_click = false;
    this.show_close_button         = false;

    if(opts != null)
      this.options = opts;

    this.options.forEach((k,v) {

      var button = new ButtonComponent();
      button.caption = v["caption"];
      button.roles = ["option_$k"];
      button.lockable = false;
      addChild(button);
      if(v["type"] != null)
        button.dom_element.classes.add(v["type"]);

      // Create click event handlers for each option button
      event_handlers.add(event: Component.click_event, role: "option_$k", handler: (self,publisher) {
        self.hide();
        _completer.complete(v["value"]);
      });

    });

  }

  void prvt_appendChildDomElement(HtmlElement el) {
    if(el.attributes["data-component-class"] == "ButtonComponent")
      findPart("button_container").append(el);
    else
      this.dom_element.append(el);
  }

}
