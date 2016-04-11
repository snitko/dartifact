part of nest_ui;

class Component extends Object with observable.Subscriber,
                                    observable.Publisher,
                                    HeritageTree,
                                    Attributable
{

  Map         behaviors = {}; // 
  HtmlElement dom_element;    // A DOM element associated with this component
  
  Component() {
  }

}
