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

  Map attribute_callbacks = {
    'default' : (attr_name, self) {
      self.attribute_callbacks_history.add("$attr_name updated");
      self.attribute_callbacks_collection['write_property_to_dom'](attr_name, self);
    }
  };

  List events_history = [];
  List attribute_callbacks_history = [];
  List native_events  = ["click", "mouseover", "text_field.click", '!mouseout'];
  MyComponent() : super() {

    event_handlers.addForEvent('click',
      {
        #self:             (self,event) => self.events_history.add(["MyComponent.self#clicked", event]),
        'self.text_field': (self,event) => self.events_history.add("MyComponent.text_field#clicked"),
        'role1':           (self,publisher) => self.events_history.add("MyComponent.role1#clicked")
      }
    );
    
    // This event is not preventing default...
    event_handlers.add(event: 'mouseout', role: #self, handler: (self,event) => self.events_history.add("self#mouseout"));
    // ...and this one is not prevented!
    event_handlers.add(event: 'mouseover', role: #self, handler: (self,event) => self.events_history.add("self#mouseover"));

  }

}

class MyChildComponent extends Component {

  List events_history = [];

  List native_events  = ["click"];
  final List attribute_names = ['property1', 'property2', 'property3', 'property4', 'validation_errors_summary'];

  List event_lock_for = ['click'];

  List hellos = [];
  sayHello(s) => hellos.add(s);
  afterInitialize() => this.events_history.add("initialized");

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
    c.afterInitialize();
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

    test("runs afterInitialize when initialized by a parent", () {
      c.initChildComponents();
      expect(c.children[0].events_history[0], equals('initialized'));
    });

    test("checks whether a particular node is a descendant of the component", () {
      var el1 = new DivElement();
      var el2 = new DivElement();
      el.append(el1);
      expect(c.prvt_hasNode(el1), isTrue);
      expect(c.prvt_hasNode(el2), isFalse);
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

    group("events", () {

      setUp(() {
        c.initChildComponents();
      });

      test("propagate from child to parent", () {
        child_component_el.click();
        expect(c.events_history[0], equals("MyComponent.role1#clicked"));
      });

      test("lock and do not allow a similar event to be handled twice", () {
        // First event
        child_component_el.click();
        expect(c.events_history, contains("MyComponent.role1#clicked"));
        c.events_history = [];

        // Second event, not supposed to be handled:
        child_component_el.click();
        expect(c.events_history, isNot(contains("MyComponent.role1#clicked")));
      });
      
    });
    

    group("native events", () {

      test("streams native browser events and applies component handlers", () {
        el.click();
        expect(c.events_history[0][0], equals("MyComponent.self#clicked"));
      });

      test("captures and streams native browser events for dom_element children and applies component handlers", () {
        var component_part = new DivElement();
        component_part.setAttribute('data-component-part', 'text_field');
        el.append(component_part);
        c.dom_element = el;
        component_part.click();
        expect(c.events_history[0], equals("MyComponent.text_field#clicked"));
      });

      test("invokes default browser event handler", () {

        var e1 = new MouseEvent('mouseout');
        el.dispatchEvent(e1);
        expect(c.events_history[0], equals("self#mouseout"));
        expect(e1.defaultPrevented, equals(false));

        var e2 = new MouseEvent('mouseover');
        el.dispatchEvent(e2);
        expect(c.events_history[1], equals("self#mouseover"));
        expect(e2.defaultPrevented, equals(true));

      });

      test("passes event object in data", () {
        el.click();
        expect(c.events_history[0][0], equals("MyComponent.self#clicked"));
        expect((c.events_history[0][1] is Event), isTrue);
      });
      

    });

    group("when a property changes", () {
      
      test("dom_element changes its text", () {
        c.dom_element.setAttribute('data-component-property', 'property1');
        c.property1 = "new value";
        expect(c.dom_element.text, equals("new value"));
      });

      test("changes its html attribute", () {
        c.dom_element.setAttribute('data-component-attribute-properties', 'property2:ok-property2');
        c.property2 = "new value";
        expect(c.dom_element.getAttribute("ok-property2"), equals("new value"));
      });

      test("removes the attribute from the property element if property is null", () {
        c.dom_element.setAttribute('data-component-attribute-properties', 'property2:ok-property2');
        c.property2 = null;
        expect(c.dom_element.attributes.keys, isNot(contains("ok-property2")));
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
        property_node.setAttribute('data-component-attribute-properties', 'property2:ok-property2');
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

    group("property updates from node", () {

      var property_node1 = new DivElement();
      var property_node2 = new DivElement();

      setUp(() {
        property_node1.setAttribute('data-component-property', 'property1');
        property_node2.setAttribute('data-component-attribute-properties', 'property2:ok-property2');
        c.dom_element.append(property_node1);
        c.dom_element.append(property_node2);
        property_node1.text = "new value";
        property_node2.setAttribute('ok-property2', 'new value');
      });
    
      test("updates property from node", () {
        c.prvt_readPropertyFromNode('property1');
        c.prvt_readPropertyFromNode('property2');
        expect(c.property1, equals("new value"));
        expect(c.property2, equals("new value"));
      });

      test("updates all properties from nodes", () {
        c.updatePropertiesFromNodes();
        expect(c.property1, equals("new value"));
        expect(c.property2, equals("new value"));
      });

      test("invokes callbacks after updating all properties from nodes", () {
        c.updatePropertiesFromNodes(invoke_callbacks: true);
        expect(c.attribute_callbacks_history[0], equals("property1 updated"));
        expect(c.attribute_callbacks_history[1], equals("property2 updated"));
      });

      test("if property is empty in DOM, assign null to the component", () {
        property_node1.text = "";
        property_node2.setAttribute('ok-property2', "");
        c.updatePropertiesFromNodes();
        expect(c.property1, isNull);
        expect(c.property2, isNull);
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
          expect(el.style.display, equals('block'));
        });

        test("shows an element with the specified display value", () {
          c.dom_element.style.display="none";
          c.dom_element.attributes['data-component-display-value'] = 'inline-block';
          c.behave('show');
          expect(el.style.display, equals('inline-block'));
        });

        test("toggles visibility", () {
          c.behave('toggleDisplay');
          expect(el.style.display, equals('none'));
          c.behave('toggleDisplay');
          expect(el.style.display, equals('block'));
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
