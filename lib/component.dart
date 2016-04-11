part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable
{

  List        native_events = [];  // events emitted by the browser that we'd like to handle
  Map         behaviors     = {};  // 
  HtmlElement dom_element;         // A DOM element associated with this component
  
  Component(HtmlElement this.dom_element) {
    native_events.forEach((e) {
      dom_element.on[e].listen((e) => this.captureEvent(e.type, ['self']));
    });
  }

}
