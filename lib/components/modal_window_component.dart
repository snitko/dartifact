part of nestui;

class ModalWindowComponent extends Component {

  List native_events   = ["close.click", "background.click"];
  List attribute_names = ["close_on_escape", "close_on_background_click", "show_close_button"];
  Map default_attribute_values = {
    "close_on_escape"           : true,
    "close_on_background_click" : true,
    "show_close_button"         : true
  };

  var content;

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
  ModalWindowComponent(this.content, [attrs=null]) {

    // TODO: settings attrs through constructor should be a Component
    // responsibility
    if(attrs != null) {
      attrs.forEach((k,v) {
        this.attributes[k] = v;
      });
    }

  }

  afterInitialize() {
    super.afterInitialize();

    if(this.show_close_button)
      event_handlers.add(event: 'click', role: "self.close", handler: (self,event) => self.behave("hide"));
    else
      this.behave("hideCloseButton");

    if(this.close_on_background_click)
      event_handlers.add(event: 'click', role: "self.background", handler: (self,event) => self.behave("hide"));

    // Workaround. Dart doesn't catch keydown events on divs, only on document -
    // but, surprise, it corretly sets the target, so we can still get it!
    document.onKeyDown.listen((e) => prvt_processKeyDownEvent(e));

    // create event_handler for ESC press

    if(this.content is String)
      content_el.text = this.content;
    else if(this.content is HtmlElement)
      content_el.append(this.content);
    else if(this.content is Component) {
      content_el.append(this.content.dom_element);
      addChild(this.content);
    }

    behave("show");

  }

  get content_el => findPart("content");
  get text       => _text;

  set text(String t) {
    _text = t;
    this.content_el.text(t);
  }

  void prvt_processKeyDownEvent(e) {
    if(this.prvt_hasNode(e.target) && e.keyCode == KeyCode.ESC && close_on_escape)
      this.behave("hide");
  }

}
