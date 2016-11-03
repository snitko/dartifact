part of nestui;

class ModalWindowComponent extends Component {

  List attribute_names = ["close_on_escape", "close_on_background_click", "show_close_button"]

  /** This can be replaced at will, but if we just want to display a text -
    * this is the default element in which the text is going to appear.
    */

  /** This the text that's going to appear inside the content element.
    * Only set this property using getter `text` and only if you want to display a simple message,
    * as it will basically remove every child of the #content element and set the HtmlElement's #text property.
    */
  String _text;

  /** Creates and displays the new modal window. The argument passed
    * may either be an HtmlElement - in which case it will appear inside the modal window,
    * or a simple string of text, which will appear inside the default #content element.
    */
  ModalWindowComponent(content) {

    if(this.show_close_button)
      event_handlers.add(event: 'click', role: "self.close_button", handler: (self,event) => self.behave("hide"));
    else
      self.behave("hideCloseButton");

    if(this.close_on_background_click)
      event_handlers.add(event: 'click', role: "self.background",   handler: (self,event) => self.behave("hide"));

    // create event_handler for ESC press

    // check if content is String or HtmlElement
      // if String - set #content_el's text property
      // if HtmlElement - append DivElement in #content_el with it
      // if Component - add component to children, append child's dom_element to #content_el

    behave("show");
  }

  get content_el => findPart("content");
  get text       => _text;

  set text(String t) {
    _text = t;
    this.content_el.text(t);
  }

}
