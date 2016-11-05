part of nest_ui;

class DialogWindowComponent extends ModalWindowComponent {

  /** This defines Button roles and captions and the values the window's Future
    * returns when one of the buttons is pressed.
    *
    * The keys in the Map are button roles, the inside of the nested map
    * is sort of self-descriptive. Perhaps "type" should be explained:
    * it basically adds the right kind of html class to the button.
    */
  Map options = { "ok" : { "caption": "OK", "type" : null, "value": true} };

  /** This is the Future containing the value returned by the window
    * when it closes. Depends on which button was clicked. */
  Completer _completer = new Completer();

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
      addChild(button);
      button.dom_element.classes.add(v["type"]);

      // Create click event handlers for each option button
      event_handlers.add(event: "click", role: "option_$k", handler: (self,publisher) {
        self.hide();
        _completer.complete(v["value"]);
      });

    });

  }

  get completed => _completer.future;

  void prvt_appendChildDomElement(HtmlElement el) {
    if(el.attributes["data-component-class"] == "ButtonComponent")
      findPart("button_container").append(el);
    else
      this.dom_element.append(el);
  }

}
