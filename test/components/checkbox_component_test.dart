import "package:test/test.dart";
import "dart:html";
import "dart:async";
import "../../lib/dartifact.dart";
import "package:mockito/mockito.dart";

part "../../lib/components/checkbox_component.dart";
part "../../lib/behaviors/checkbox_component_behaviors.dart";
part "../../lib/test_helpers/component_test_helpers.dart";

@TestOn("browser")

class CheckboxComponentBehaviorMock extends Mock implements CheckboxComponentBehaviors {}

void main() {
  var root, checkbox;

  setUp(() {
    root = createComponent("RootComponent", el: document.body, and: (parent) {
      var el = createDomEl("CheckboxComponent", attr_properties: "checked:data-checked", attrs: { "data-checked": true });
      return [el];
    });
    checkbox = root.children.first;
    checkbox.ignore_misbehavior = false;
    checkbox.behavior_instances = [new CheckboxComponentBehaviorMock()];
  });

  test("reads #checked from DOM after initialization", () {
    expect(checkbox.checked, equals(true));
  });

  test("invokes check/uncheck behavior after #checked attr is changed", () {
    checkbox.checked = false;
    verify(checkbox.behavior_instances[0].uncheck());
    checkbox.checked = true;
    verify(checkbox.behavior_instances[0].check());
  });
}
