part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable
{

  List        native_events = [];  // events emitted by the browser that we'd like to handle
  Map         behaviors     = {};  // 
  HtmlElement _dom_element;        // A DOM element associated with this component

  get dom_element => _dom_element;
  set dom_element(HtmlElement el) {
    _dom_element = el;
    _listen_to_native_events();
  }
  
  Component() {
  }

  _listen_to_native_events() {
     this.native_events.forEach((e) {
      dom_element.on[e].listen((e) => this.captureEvent(e.type, [#self]));
    }); 
  }

}
