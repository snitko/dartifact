import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/modal_window_component.dart';
part '../../lib/components/dialog_window_component.dart';
part '../../lib/behaviors/modal_window_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/dialog_window_component_test_helpers.dart';

@TestOn("browser")

class MockModalWindowComponentBehaviors extends Mock implements ModalWindowComponentBehaviors {}

void main() {

  var dw, root, behaviors;

  setUp(() {
    root = createComponent("RootComponent", el: document.body);
    var el = createDialogWindowElement();
    el.attributes["data-component-template"] = "DialogWindowComponent";
    document.body.append(el);
    var button_el = createDomEl("ButtonComponent");
    button_el.attributes["data-component-template"] = "ButtonComponent";
    document.body.append(button_el);
  });

  group("DialogWindowComponent", () {

    var yes_button, no_button;

    setUp(() {
      dw = new DialogWindowComponent("hello world", {
        "yes" : { "caption": "Yes", "type": "green", "value": "YES CLICKED" },
        "no" :  { "caption": "No",  "type": "blue",  "value": "NO CLICKED"  }
      });
      yes_button = dw.findFirstChildByRole("option_yes");
      no_button  = dw.findFirstChildByRole("option_no");
    });

    test("creates an option button for each option", () {
      expect(yes_button, isNotNull);
      expect(no_button, isNotNull);
    });

    test("button's dom_elements are added in to a special button container", () {
      expect(dw.findPart("button_container").children.length, equals(2));
      dw.findPart("button_container").children.forEach((b) {
        expect(b.attributes["data-component-class"], equals("ButtonComponent"));
      });
    });

    test("returns a future from the #completed property", () {
      expect(dw.completed is Future, isTrue);
    });

    test("creates an event handler for option button", () {
      expect(dw.event_handlers.map["click"].keys, contains("option_yes"));
      expect(dw.event_handlers.map["click"].keys, contains("option_no"));
    });

    test("the completed future returns what the button says it should", () {
      yes_button.dom_element.click();
      dw.completed.then((r) {
        expect(r, equals("YES CLICKED"));
      });
    });

    test("closes the window then the future is completed", () {
      dw.ignore_misbehavior = false;
      var behaviors = new MockModalWindowComponentBehaviors();
      when(behaviors.show()).thenReturn(new Completer().future);
      when(behaviors.hide()).thenReturn(new Completer().future);
      dw.behavior_instances = [behaviors];
      yes_button.dom_element.click();
      verify(dw.behavior_instances[0].hide());
    });

    test("adds appropriate 'type' passed in the option Map as a class to the Button", () {
      expect(yes_button.dom_element.classes, contains("green"));
      expect(no_button.dom_element.classes, contains("blue"));
    });

  });

}
