import '../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyComponent extends Component {

  Map event_handlers = {
    'click' : { #self: (self) => self.events_history.add("self#clicked") }
  };

  final List attribute_names = ['property1', 'property2', 'property3', 'property4'];

  List events_history = [];
  List native_events  = ["click", "mouseover"];
  MyComponent() : super();

}

void main() {

  var c;
  var el;

  setUp(() {
    el            = new DivElement();
    c             = new MyComponent();
    c.dom_element = el;
  });

  group("Component", () {
    
    test("streams native browser events and applies component handlers", () {
      el.click();
      expect(c.events_history[0], equals("self#clicked"));
    });

    test("can behave", () {
      c.behave('hide');
      expect(el.style.display, equals('none'));
    });

    group("when a property changes", () {
      
      test("dom_element changes its text", () {
        c.dom_element.setAttribute('data-component-property', 'property1');
        c.property1 = "new value";
        expect(c.dom_element.text, equals("new value"));
      });

      test("dom_element changes its html attribute", () {
        c.dom_element.setAttribute('data-component-property', 'property1');
        c.dom_element.setAttribute('data-component-property-attr-name', 'ok-property1');
        c.property1 = "new value";
        expect(c.dom_element.getAttribute("ok-property1"), equals("new value"));
      });

      test("child of the dom element changes its text", () {
        var property_node = new DivElement();
        property_node.setAttribute('data-component-property', 'property2');
        c.dom_element.append(property_node);
        c.property2 = "new value";
        expect(property_node.text, equals("new value"));
      });

      test("child of the dom element changes its html attribute", () {
        var property_node = new DivElement();
        property_node.setAttribute('data-component-property', 'property2');
        property_node.setAttribute('data-component-property-attr-name', 'ok-property2');
        c.dom_element.append(property_node);
        c.property2 = "new value";
        expect(property_node.getAttribute("ok-property2"), equals("new value"));
      });

      test("skips children of the dom_element which are themselves components", () {
        var property_node   = new DivElement();
        var child_component = new DivElement();
        property_node.setAttribute('data-component-property', 'property3');
        child_component.setAttribute('data-component-property', 'property3');
        child_component.setAttribute('data-component-id', 'child-component-1');
        c.dom_element.append(child_component);
        c.dom_element.append(property_node);
        c.property3 = "new value";
        expect(child_component.text, equals(""));
        expect(property_node.text,   equals("new value"));
      });

    });

  });

}
