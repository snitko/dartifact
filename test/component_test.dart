import '../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyComponent extends Component {

  Map event_handlers = {
    'click' : {
      #self:             (self) => self.events_history.add("self#clicked"),
      'self.text_field': (self) => self.events_history.add("self.text_field#clicked")
    }
  };

  final List attribute_names = ['property1', 'property2', 'property3', 'property4'];

  List events_history = [];
  List native_events  = ["click", "mouseover", "text_field.click"];
  MyComponent() : super();

}

class MyChildComponent extends Component {}

void main() {

  var c;
  var el;
  var c_template;

  setUp(() {
    c_template = new DivElement();
    c_template.setAttribute('data-component-template', 'MyComponent');
    c_template.className = 'myComponent';
    document.documentElement.append(c_template);
    el            = new DivElement();
    c             = new MyComponent();
    c.dom_element = el;
  });

  group("Component", () {

    test("can behave", () {
      c.behave('hide');
      expect(el.style.display, equals('none'));
    });

    test("creates child components out of the descendant dom elements", () {
      var child_component_el = new DivElement();
      child_component_el.setAttribute('data-component-class', 'MyChildComponent');
      el.append(child_component_el);
      c.initChildComponents();
      expect(c.children[0], isNotNull);
      expect(c.children[0].dom_element, equals(child_component_el));
      expect(c.children[0].parent, equals(c));
    });

    test("assigns child components roles from data-component-role attribute", () {
      var child_component_el = new DivElement();
      child_component_el.setAttribute('data-component-class', 'MyChildComponent');
      child_component_el.setAttribute('data-component-roles', 'role1,role2');
      el.append(child_component_el);
      c.initChildComponents();
      expect(c.children[0].roles, equals(["role1", "role2"]));
    });

    group("native events", () {

      test("streams native browser events and applies component handlers", () {
        el.click();
        expect(c.events_history[0], equals("self#clicked"));
      });

      test("captures and streams native browser events for dom_element children and applies component handlers", () {
        var component_part = new DivElement();
        component_part.setAttribute('data-component-part', 'text_field');
        el.append(component_part);
        c.dom_element = el;
        component_part.click();
        expect(c.events_history[0], equals("self.text_field#clicked"));
      });

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

    group("templates", () {
      
      test("templates are identified in the dom", () {
        expect(c.template.className, equals('myComponent'));
      });

      test ("templates are cloned and set as #dom_element, data-component-template attr removed", () {
        c.initDomElementFromTemplate();
        expect(c.template.getAttribute('data-component-template'), equals('MyComponent'));
        expect(c.dom_element.className, equals('myComponent'));
        expect(c.dom_element.getAttribute('data-component-template'), equals(null));
        expect(c.dom_element.getAttribute('data-component-class'), equals('MyComponent'));
      });

      test ("all properties are correctly set to the newly assigned #dom_element created from a template", () {
        c.template.setAttribute('data-component-property', 'property1');
        c.property1 = 'hello';
        c.initDomElementFromTemplate();
        expect(c.dom_element.text, equals('hello'));
      });

    });

  });

}
