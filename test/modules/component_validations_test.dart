import '../../lib/dartifact.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyComponent extends Component {

  final List attribute_names = ['property1', 'property2', 'property3', 'property4', 'validation_errors_summary'];

  Map validations = {
    'role1.role3.property1': { 'isNotNull' : true },
    'role1.property1':       { 'isNotNull' : true },
    'property1':             { 'isNotNull' : true },
    'role1.value':           { "function": { "name": "customValidation", "message": "custom validation failed" }}
  };

  prvt_customValidation() => this.children[0].value == "value";

}

class MyChildComponent extends Component {
  final List attribute_names = ['property1', 'property2', 'property3', 'property4', "value", 'validation_errors_summary'];
}

void main() {

  var c;
  var el;

  setUp(() {
    el            = new DivElement();
    c             = new MyComponent();
    c.dom_element = el;
    c.afterInitialize();
  });

  group("ComponentValidations", () {

    group("validation of children", () {

      var child_component_el  = new DivElement();
      var child_component_el2 = new DivElement();

      setUp(() {
        child_component_el.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el.setAttribute('data-component-roles', 'role1,role2');
        el.append(child_component_el);
        child_component_el2.setAttribute('data-component-class', 'MyChildComponent');
        child_component_el2.setAttribute('data-component-roles', 'role3,role4');
        child_component_el.append(child_component_el2);
        c.initChildComponents();
        c.afterInitialize();
      });

      test("it defines validation on all descendants with a specific role", () {
        expect(c.children[0].validations.keys, contains('property1'));
        expect(c.children[0].validations.keys, contains('value'));
        expect(c.children[0].children[0].validations.keys, contains('property1'));
      });

      test("collect validation errors in validation_errors_summary as a String", () {
        c.validate(deep: false);
        expect(c.validation_errors_summary, startsWith('property1: should not be null'));
        // Not deep validation!
        expect(c.children[0].validation_errors, isEmpty);
      });

      test("run validations on children too", () {
        c.validate(deep: true);
        expect(c.children[0].validation_errors_summary, startsWith('property1: should not be null'));
        expect(c.children[0].children[0].validation_errors_summary, equals('property1: should not be null'));
      });

      test("runs custom validation function from the parent, but adds error to the child", () {
        c.validate(deep: true);
        expect(c.children[0].validation_errors["value"], isNot(isNull));
      });

      test("shows the validation errors summary block if invalid after validation", () {
        
      });

      test("hides the validation errors summary block if valid after validation", () {
        
      });
      
    });
    
  });

}
