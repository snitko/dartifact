import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/button_component.dart';
part '../../lib/behaviors/button_component_behaviors.dart';
part '../../lib/test_helpers/component_test_helpers.dart';

@TestOn("browser")

class ButtonComponentBehaviorMock extends Mock implements ButtonComponentBehaviors {}

void main() {

  var root, button;

  setUp(() {
    root = createComponent("RootComponent", el: document.body, and: (parent) {
      var button_el = createDomEl("ButtonComponent",
        attr_properties: "lockable:data-lockable,disabled:data-disabled",
        attrs: { "data-lockable": false, "data-disabled": true }
      );
      return [button_el];
    });
    button = root.children.first;
    button.ignore_misbehavior = false;
    button.behavior_instances = [new ButtonComponentBehaviorMock()];
  });

  test("reads #lockable and #disabled from the DOM after it is initialized", () {
    expect(button.lockable, equals(false));
    expect(button.disabled, equals(true));
  });

  test("invokes disable/enable behavior after #disabled attr is changed", () {
    button.disabled = false;
    verify(button.behavior_instances[0].enable());
    button.disabled = true;
    verify(button.behavior_instances[0].disable());
  });

  test("invokes lock behavior after it's clicked, but only if #lockable is true", () {
    button.dom_element.click();
    button.lockable = true;
    button.dom_element.click();
    verify(button.behavior_instances[0].lock());
  });

}
