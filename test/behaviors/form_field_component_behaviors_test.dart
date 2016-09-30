import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import '../../lib/nest_ui.dart';

part '../../lib/components/form_field_component.dart';
part '../../lib/behaviors/form_field_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/form_field_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var form_field, behaviors;

  group("FormFieldComponentBehaviors", () {

    setUp(() {
      form_field = createFormFieldComponent();
    });

    test("shows/hides errors", () {
      var errors_el = form_field.dom_element.querySelector("[data-component-property=\"validation_errors_summary\"]");
      form_field.behave("showErrors");
      expect(errors_el.style.display, equals("block"));
      expect(form_field.dom_element.classes, contains("errors"));
      form_field.behave("hideErrors");
      expect(errors_el.style.display, equals("none"));
      expect(form_field.dom_element.classes, isNot(contains("errors")));
    });

    test("disables/enables the value_holder field", () {
      form_field.behave("disable");
      expect(form_field.value_holder_element.attributes, contains("disabled"));
      expect(form_field.disabled, isTrue);
      form_field.behave("enable");
      expect(form_field.value_holder_element.attributes, isNot(contains("disabled")));
      expect(form_field.disabled, isFalse);
    });

    
  });

}
