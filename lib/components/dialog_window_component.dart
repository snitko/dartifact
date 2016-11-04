part of nest_ui;

class DialogWindowComponent extends ModalWindowComponent {

  /** This defines Button roles and captions and the values the window's Future
    * returns when one of the buttons is pressed.
    * Syntax:
    *
    *   { "role" : ["caption", value_to_be_returned] }
    */
  Map options = { "ok" : ["OK", true] };

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

    // Create a button for each option

    // Create click event handlers for each option button
    this.options.forEach((k,v) {
      event_handlers.add(event: "click", role: "option_${k}", handler: (self,publisher) {
        this.hide();
        _completer.complete(v[1]);
      });
    });

  }

  get completed => _completer.future;

  // redefine method that adds buttons as child elements

}
