import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/dartifact.dart';
part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/radio_button_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var radio;
  Component.app_library = "dartifact";

  setUp(() {
    // values in option elements are: value1, value2, value3
    radio = createRadioButtonComponent();
  });

  test("sets value from DOM", () {
    radio.findAllParts("option").last.checked = true;
    radio.findAllParts("option").last.dispatchEvent(new Event("change"));
    expect(radio.value, equals("value3"));
    radio.findAllParts("option").last.checked = false;
    radio.findAllParts("option").first.checked = true;
    radio.findAllParts("option").last.dispatchEvent(new Event("change"));
    radio.findAllParts("option").first.dispatchEvent(new Event("change"));
    expect(radio.value, equals("value1"));
  });

  test("loads all options and their DOM elements from DOM into the #options List", () {
    expect(radio.options.keys, equals(["value1", "value2", "value3"]));
  });

  test("selects option based on the current value", () {
    radio.value = "value1";
    expect(radio.findAllParts("option")[0].checked, isTrue);
    expect(radio.findAllParts("option")[1].checked, isFalse);
    expect(radio.findAllParts("option")[2].checked, isFalse);
    radio.value = "value2";
    expect(radio.findAllParts("option")[0].checked, isFalse);
    expect(radio.findAllParts("option")[1].checked, isTrue);
    expect(radio.findAllParts("option")[2].checked, isFalse);
    radio.value = "value3";
    expect(radio.findAllParts("option")[0].checked, isFalse);
    expect(radio.findAllParts("option")[1].checked, isFalse);
    expect(radio.findAllParts("option")[2].checked, isTrue);
  });

  test("raises exception if none of the options have the value that's being set", () {
    expect(() => radio.value = "some other value", throwsA(new isInstanceOf<NoOptionWithSuchValue>()));
  });

  test("sets value from the selected DOM option", () {
    radio.findAllParts("option")[1].checked = true;
    radio.setValueFromSelectedOption();
    expect(radio.value, equals("value2"));
  });

}
