import '../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyComponent extends Component {

  final List attribute_names = ['property1', 'property2', 'property3', 'property4', 'validation_errors_summary'];

  Map validations = {
    'role1.role3.property1': { 'isNotNull' : true },
    'role1.property1':       { 'isNotNull' : true },
    'property1':             { 'isNotNull' : true }
  };

  List events_history = [];
  List native_events  = ["click", "mouseover", "text_field.click"];
  MyComponent() : super() {
    event_handlers.add_for_event('click',
      {
        #self:             (self,p) => self.events_history.add("self#clicked"),
        'self.text_field': (self,p) => self.events_history.add("self.text_field#clicked"),
        'role1':           (self,p) => self.events_history.add("role1#clicked")
      }
    );
  }

}

class MyChildComponent extends Component {
  List native_events  = ["click"];
  final List attribute_names = ['property1', 'property2', 'property3', 'property4', 'validation_errors_summary'];

  List hellos = [];
  sayHello(s) => hellos.add(s);
}

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

    var child_component_el;

    setUp(() {
      child_component_el = new DivElement();
      child_component_el.setAttribute('data-component-class', 'MyChildComponent');
      child_component_el.setAttribute('data-component-roles', 'role1,role2');
      el.append(child_component_el);
    });

    test("creates child components out of the descendant dom elements", () {
      c.initChildComponents();
      expect(c.children[0], isNotNull);
      expect(c.children[0].dom_element, equals(child_component_el));
      expect(c.children[0].parent, equals(c));
    });

    test("assigns child components roles from data-component-role attribute", () {
      c.initChildComponents();
      expect(c.children[0].roles, equals(["role1", "role2"]));
    });

    test("it propagates events from child to parent", () {
      c.initChildComponents();
      child_component_el.click();
      expect(c.events_history[0], equals("role1#clicked"));
    });

    test("adding a child appends it to the dom_element's parent by default", () {
      // it's okay, we can add MyComponent as a child of MyComponent, who's going to stop us?
      var new_component = new MyComponent();
      c.addChild(new_component);
      expect(c.dom_element.children[1], equals(new_component.dom_element));
    });

    test("calls a method on all of its children", () {
      c.initChildComponents();
      c.applyToChildren('sayHello', ['hi']);
      expect(c.children[0].hellos, equals(['hi']));
    });
    

    group("removing a component", () {

      test("removing a component removes its DOM element too", () {
        c.remove();
        expect(c.dom_element, isNull);
      });

      test("removing a component removes it from its parent children's list", () {
        c.initChildComponents();
        var child = c.children[0];
        c.children[0].remove();
        expect(c.children.length, equals(0));
        expect(child.parent, isNull);
      });

      test("deep removal of the component removes all of its descendants and their DOM elements", () {
        var child_component_el2 = new DivElement();
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
        var descendant1 = c.children[0];
        var descendant2 = c.children[0].children[0];
        expect(descendant1 is MyChildComponent, isTrue);
        c.remove(deep: true);
        expect(descendant1.children.length, equals(0));
        expect(descendant2.parent, isNull);
      });

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
        child_component.setAttribute('data-component-class', 'MyComponent');
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

    group("standard behaviors", () {

      group("visibility", () {
        
        test("hides an element", () {
          c.behave('hide');
          expect(el.style.display, equals('none'));
        });

        test("shows an element", () {
          c.dom_element.style.display="none";
          c.behave('show');
          expect(el.style.display, equals(''));
        });

        test("toggles visibility", () {
          c.behave('toggleDisplay');
          expect(el.style.display, equals('none'));
          c.behave('toggleDisplay');
          expect(el.style.display, equals(''));
        });

      });

      group("locking/unlocking", () {
        
        test("adds 'locked' class to a locked element", () {
          c.behave('lock');
          expect(el.classes, contains('locked'));
        });

        test("removes 'locked' class from an unlocked element", () {
          c.dom_element.classes.add("locked");
          c.behave('unlock');
          expect(el.classes, isNot(contains('locked')));
        });

        test("toggles between locked and unlocked by adding/removing 'locked' class", () {
          c.behave('toggleLock');
          expect(el.classes, contains('locked'));
          c.behave('toggleLock');
          expect(el.classes, isNot(contains('locked')));
        });

      });

      group("disabling/enabling", () {
        
        test("adds 'disabled' class and attribute to a locked element", () {
          c.behave('disable');
          expect(el.classes,    contains('disabled'));
          expect(el.attributes, contains('disabled'));
        });

        test("removes 'disabled' class and attribute from a locked element", () {
          c.dom_element.classes.add("disabled");
          c.dom_element.setAttribute("disabled", "disabled");
          c.behave('enable');
          expect(el.classes,    isNot(contains('disabled')));
          expect(el.attributes, isNot(contains('disabled')));
        });

        test("toggles between locked and unlocked by adding/removing .locked class", () {
          c.behave('disable');
          expect(el.classes, contains('disabled'));
          expect(el.attributes, contains('disabled'));
          c.behave('enable');
          expect(el.classes, isNot(contains('disabled')));
          expect(el.attributes, isNot(contains('disabled')));
        });

      });
      
    });

    group("finding descendants by roles", () {

      test("finds all children with a specific role", () {
        c.initChildComponents();
        expect(c.findChildrenByRole('role1'), equals([c.children[0]]));
        expect(c.findChildrenByRole('role100'), equals([]));
      });

      test("finds all descendants with a specific role using . as a parent qualifier", () {
        var child_component_el2 = new DivElement();
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el2.setAttribute('data-component-roles', 'role3,role4');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
        expect(c.findDescendantsByRole('role1.role3'), equals([c.children[0].children[0]]));
      });

    });

    group("validation of children", () {

      var child_component_el2 = new DivElement();

      setUp(() {
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el2.setAttribute('data-component-roles', 'role3,role4');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
      });

      test("it defines validation on all descendants with a specific role", () {

        expect(c.children[0].validations, equals({
          'property1': { 'isNotNull'  : true }
        }));

        expect(c.children[0].children[0].validations, equals({
          'property1': { 'isNotNull'  : true }
        }));

      });

      test("collect validation errors in validation_errors_summary as a String", () {
        c.validate(deep: false);
        expect(c.validation_errors_summary, equals('property1: should not be null'));
        // Not deep validation!
        expect(c.children[0].validation_errors, isEmpty);
      });

      test("run validations on children too", () {
        c.validate(deep: true);
        expect(c.children[0].validation_errors_summary, equals('property1: should not be null'));
        expect(c.children[0].children[0].validation_errors_summary, equals('property1: should not be null'));
      });

      test("shows the validation errors summary block if invalid after validation", () {
        
      });

      test("hides the validation errors summary block if valid after validation", () {
        
      });
      
      
      
    });
    
  });

}
