import '../../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyFormFieldComponent extends FormFieldComponent {

  Map validations = {
    'value': { 'isNotNull' : true }
  };

}

void main() {

  var c;

  setUp(() {
    c = new MyFormFieldComponent();
    c.after_initialize();
  });

  test("catches change event from the dom_element", () {
    c.dom_element = new TextAreaElement();
    c.dom_element.value = 'some text';
    c.dom_element.dispatchEvent(new Event("change"));
    expect(c.value, equals('some text'));
  });

  test("catches change event from the dom_element descendant which has a part name 'value_holder'", () {
    c.dom_element = new DivElement();
    var text_area = new TextAreaElement();
    text_area.setAttribute('data-component-part', 'value_holder');
    c.dom_element.append(text_area);
    c.dom_element.children[0].value = 'some text';
    c.dom_element.children[0].dispatchEvent(new Event("change"));
    expect(c.value, equals('some text'));
  });

  test("show and hide validation_errors_summary block accordingly", () {
    c.dom_element           = new DivElement();
    var text_area           = new TextAreaElement();
    var validations_summary = new DivElement();
    text_area.setAttribute('data-component-part', 'value_holder');
    validations_summary.setAttribute('data-component-property', 'validation_errors_summary');
    c.dom_element.append(text_area);
    c.dom_element.append(validations_summary);
    c.validate();
    expect(c.dom_element.children[1].style.display, equals(''));
    c.value = 1;
    c.validate();
    expect(c.dom_element.children[1].style.display, equals('none'));
  });

  test("resets an element value", () {
    c.dom_element       = new TextAreaElement();
    c.dom_element.value = 'some text';
    c.dom_element.dispatchEvent(new Event("change"));
    c.reset();
    expect(c.value, isNull);
    expect(c.value_holder_element.value, '');
  });
  
  

}
