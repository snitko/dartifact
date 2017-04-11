import '../../lib/dartifact.dart';
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
      expect(c.value, equals(10));
      c.value = "10a";
      expect(c.value, equals(10));
    });

    test("doesn't allow value to be more than max_length", () {
      c.max_length = 15;
      c.value = "12345678901234567";
      expect(c.value, equals(null));
      c.value = "123456789012345";
      expect(c.value, equals(123456789012345));
    });

    test("ingores incorrect non-numeric values and sets value to null instead", () {
      c.value = ".";
      expect(c.value, isNull);
      c.value = ".0";
      expect(c.value, isNull);
      c.value = "1.";
      expect(c.value, isNull);
      c.value = "1.2345";
      expect(c.value, equals(1.2345));
      c.value = 1.5432;
      expect(c.value, equals(1.5432));
    });
    
    

  });
  

}
