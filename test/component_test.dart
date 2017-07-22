import '../lib/dartifact.dart';
import "package:test/test.dart";
import "dart:html";

part "../lib/test_helpers/component_test_helpers.dart";

@TestOn("browser")

class MyComponent extends Component {

  final List attribute_names = ['property1', 'property2', 'property3', 'property4', 'validation_errors_summary'];

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
      },
    );

    event_handlers.add(event: "click", role: "role1", options: { "pass_native_event_object" : true }, handler: (self,event) =>
      self.events_history.add("MyComponent.role1(native event)#${event.type}"));
    
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

      test("doesn't propagate from child to parent if event is on the non-propagation list", () {
        c.children[0].no_propagation_native_events = ["click"];
        child_component_el.click();
        expect(c.events_history[0], isNot(equals("MyComponent.role1#clicked")));
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

      test("passes native event object if pass_native_event_object option is passed when adding an event", () {
        child_component_el.click();
        expect(c.events_history, contains("MyComponent.role1(native event)#click"));
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

      test("detects events on parts of the component that are nested in other parts in DOM", () {
        var component_part1 = new DivElement();
        var component_part2 = new DivElement();
        component_part1.setAttribute('data-component-part', 'container_part');
        component_part2.setAttribute('data-component-part', 'text_field');
        component_part1.append(component_part2);
        el.append(component_part1);
        c.dom_element = el;
        component_part2.click();
        expect(c.events_history[0], equals("MyComponent.text_field#clicked"));
      });

      test("re-creates events and catches events for newly added html elements", () {
        var component_part1 = new DivElement();
        var component_part2 = new DivElement();
        component_part1.setAttribute('data-component-part', 'text_field');
        component_part2.setAttribute('data-component-part', 'text_field');
        el.append(component_part1);

        c.dom_element = el; // attaching event listeners here
        component_part1.click();

        expect(c.events_history[0], equals("MyComponent.text_field#clicked"));
        expect(c.events_history[1], isNot(equals("MyComponent.text_field#clicked")));
        expect(c.events_history.length, equals(3));
        c.events_history.clear();

        // Checking we don't yet catch events for the newly added element,
        // because we haven't re-created listeners.
        el.append(component_part2);
        component_part2.click();
        expect(c.events_history[0], isNot(equals("MyComponent.text_field#clicked")));
        expect(c.events_history[0], isNot(equals("MyComponent.self#clicked")));
        expect(c.events_history[1], isNot(equals("MyComponent.self#clicked")));
        expect(c.events_history.length, equals(2));
        c.events_history.clear();


        // Now we re-create listeners and check the event is caught.
        c.reCreateNativeEventListeners();
        component_part2.click();
        expect(c.events_history[0], equals("MyComponent.text_field#clicked"));
        expect(c.events_history[1], isNot(equals("MyComponent.text_field#clicked")));
        expect(c.events_history.length, equals(3));

        // Checking the right number of event listeners.
        // We should have two event listeners for the text_field#click because there
        // are two text_field components!
        expect(c.native_event_listeners["text_field.click"].length, equals(2));

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

    group("finding descendants by roles", () {

      test("finds all children with a specific role", () {
        c.initChildComponents();
        expect(c.findChildrenByRole('role1'), contains(c.children[0]));
        expect(c.findChildrenByRole('role100'), equals([]));
      });

      test("finds first child with a specific role", () {
        c.initChildComponents();
        expect(c.findFirstChildByRole('role1'), equals(c.children[0]));
        expect(c.findFirstChildByRole('role100'), isNull);
      });

      test("finds all descendants with a specific role using . as a parent qualifier", () {
        var child_component_el2 = new DivElement();
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el2.setAttribute('data-component-roles', 'role3,role4');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
        expect(c.findDescendantsByRole('role1.role3'), equals([c.children[0].children[0]]));
      });

      test("finds all descendants with a specific without regard for their parent roles", () {
        var child_component_el2 = new DivElement();
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el2.setAttribute('data-component-roles', 'role3,role4');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
        expect(c.findDescendantsByRole('*.role3'), equals([c.children[0].children[0]]));
      });

    });

    group("i18n", () {

      var r;

      setUp(() {
        var root_data_holder = new InputElement();
        var component_data_holder = new InputElement();
        var my_component_data_holder = new InputElement();
        component_data_holder.attributes["data-i18n-json"] = '{ "hello" : "world", "welcome": "home", "nested" : { "hello" : "world"}}';
        component_data_holder.attributes["id"] = "i18n_Component_data_holder";
        my_component_data_holder.attributes["data-i18n-json"] = '{ "welcome" : "home2" }';
        my_component_data_holder.attributes["id"] = "i18n_MyComponent_data_holder";
        root_data_holder.attributes["data-i18n-json"] = '{ "root_hello" : "root_world" }';
        root_data_holder.attributes["id"] = "i18n_data_holder";
        document.body.append(root_data_holder);
        document.body.append(component_data_holder);
        document.body.append(my_component_data_holder);
        r = createComponent("RootComponent", and: (r) {
          c = createComponent("MyComponent");
          return [c];
        });
      });

      test("translates they key using Component's i18n instance", () {
        expect(c.t("hello"), equals("world"));
      });

      test("translates they key using Component's ancestors i18n dictionary", () {
        expect(c.t("welcome"), equals("home2"));
        expect(c.t("nested.hello"), equals("world"));
      });

      test("translates they key using RootComponent's i18n instance when key not found in Component's i18n instance", () {
        expect(c.t("root_hello"), equals("root_world"));
      });
      
    });

    test("finds all descendants which are instances of a certain Component class", () { 
      var el1 = createDomEl("MyComponent");
      var el2 = createDomEl("MyChildComponent");
      var el3 = createDomEl("MyChildComponent");
      var el4 = createDomEl("Component");
      c.dom_element.innerHtml = "";
      c.dom_element.append(el1);
      c.dom_element.append(el2);
      c.dom_element.append(el3);
      c.dom_element.append(el4);
      c.initChildComponents();
      expect(c.findAllDescendantInstancesOf("Component").length, equals(4));
      expect(c.findAllDescendantInstancesOf("MyChildComponent").length, equals(2));
      expect(c.findAllDescendantInstancesOf("MyComponent").length, equals(1));
    });
    
  });

}
