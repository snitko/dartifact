import '../../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

void main() {

  var c = new FormComponent();

  test("catches change event from the dom_element", () {
    c.dom_element = new TextAreaElement();
    c.dom_element.value = 'some text';
    c.dom_element.dispatchEvent(new Event("change"));
    expect(c.value, equals('some text'));
  });

  test("catches change event from the dom_element descendant which has a part name 'value_holder'", () {
    c.dom_element = new DivElement();
    var text_area     = new TextAreaElement();
    text_area.setAttribute('data-component-part', 'value_holder');
    c.dom_element.append(text_area);
    c.dom_element.children[0].value = 'some text';
    c.dom_element.children[0].dispatchEvent(new Event("change"));
    expect(c.value, equals('some text'));
  });
  
  

}
