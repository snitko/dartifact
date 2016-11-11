part of nestui;

/** ModalWindow is an HtmlBlock that is supposed to appear on top of all other content
  * on a page and block the user from interacting with the page until the modal window is closed.
  *
  * A new ModalWindow is created by invoking the constructor. It then automatically adds itself
  * (and, consequently, its `#dom_element`) to RootComponent. You job is to have css
  * in place to display the ModalWindow. What you probably want is to have
  * the `#dom_element` be a sort of background with some kind of opacity (like 0.3) and
  * then the `#content_el` element serving as the actual window at the center of the screen.
  *
  * The content of such window can be anything and is contained within the `#content_el`.
  * When creating a new ModalWindow, you just pass content to the constructor as the first argument:
  * it can be a String, an HtmlElement or another Component.
  *
  * The second argument to the constructor is a Map of options. The options have self-descriptive
  * names and determine how the window may be closed:
  * `close_on_escape`, `close_on_background_click` and `show_close_button` - all are bool.
  *
  */
class ModalWindowComponent extends Component {

  List native_events   = ["close.click", "background.click"];
  List attribute_names = ["close_on_escape", "close_on_background_click", "show_close_button"];
  Map default_attribute_values = {
    "close_on_escape"           : true,
    "close_on_background_click" : true,
    "show_close_button"         : true
  };
  List behaviors = [ModalWindowComponentBehaviors];

  /** Contains the content for the #content_el. It's actually only used once,
    * in the constructor while setting #content_el, so changing it accomplishes nothing.
    * You can however use the `text` setter.
    */
  var content;

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

    // TODO: setting attrs through constructor should be a Component
    // responsibility.
    if(attrs != null) {
      attrs.forEach((k,v) {
        this.attributes[k] = v;
      });
    }

    // Interesting thing about this call:
    //  1. RootComponent#addChild() gets called
    //  2. which in turn calls ModalWindowComponent#afterInitialize()
    //  3. Only after that, the execution returns to show() and behave("show") is called.
    this.show();

  }

  afterInitialize() {
    super.afterInitialize();

    if(this.show_close_button)
      event_handlers.add(event: 'click', role: "self.close", handler: (self,event) => self.hide());
    else
      this.behave("hideCloseButton");

    if(this.close_on_background_click) {
      event_handlers.add(event: 'click', role: "self.background", handler: (self,event) {
        if(event.target == findPart("background"))
          self.hide();
      });
    }

    // Workaround. Dart doesn't catch keydown events on divs, only on document -
    // but, surprise, it corretly sets the target, so we can still get it!
    document.onKeyDown.listen((e) => prvt_processKeyDownEvent(e));

    if(this.content is String)
      content_el.text = this.content;
    else if(this.content is HtmlElement)
      content_el.append(this.content);
    else if(this.content is Component) {
      content_el.append(this.content.dom_element);
      addChild(this.content);
    }

  }

  get content_el => findPart("content");
  get text       => _text;

  /** Changes the text inside the `#content_el`. Use with caution: erases everything
    * else inside the `#content_el`.
    */
  set text(String t) {
    _text = t;
    this.content_el.text(t);
  }

  /** Adds itself to RootComponent as a child, appends dom_element to it, calls show() behaviors*/
  Future show() {
    var r = RootComponent.instance;
    r.addChild(this);
    if(r.dom_element.children.length != 1) {
      r.dom_element.children.last.remove();
      r.dom_element.insertBefore(this.dom_element, r.dom_element.children.first);
    }
    return this.behave("show");
  }

  /** Removes itself to RootComponent's children list, removes itself
    * RootComponent#dom_element's children, calls hide() behavior.*/
  Future hide() {
    return this.behave("hide").then((r) {
      this.remove();
    });
  }

  void prvt_processKeyDownEvent(e) {
    if(this.prvt_hasNode(e.target, skip_components: false) && e.keyCode == KeyCode.ESC && this.close_on_escape)
      this.hide();
  }


}
