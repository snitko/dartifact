import '../../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

void main() {

  var c;
  var el;

  group("NumericFormFieldComponent", () {
    setUp(() {
      c  = new NumericFormFieldComponent();
      el = new InputElement();
      el.attributes['data-component-part'] = 'value_holder';
      c.dom_element = el;
      c.afterInitialize();
    });

    test("doesn't allow to enter non-numeric characters", () {
      c.value = "10";
      expect(c.value, equals("10"));
      c.value = "10a";
      expect(c.value, equals("10"));
    });
  });
  

}
