import "package:test/test.dart";
import "dart:html";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/modal_window_component.dart';
part '../../lib/behaviors/modal_window_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/modal_window_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var mw, behaviors, root;

  group("ModalWindowComponentBehaviors", () {

    setUp(() {
      root = createComponent("RootComponent", el: document.body);
      var el = createModalWindowElement();
      el.attributes["data-component-template"] = "ModalWindowComponent";
      document.body.append(el);
      mw = createModalWindowComponent(mock_behaviors: false);
      behaviors = mw.behavior_instances[0];
    });
 
    test("displays dom_element on show()", () {
      mw.dom_element.style.display = "none";
      behaviors.show().then((r) {
        expect(mw.dom_element.style.display, equals("block"));
      });
    });

    test("hides dom_element on hide() and removes itself from RootComponent", () {
      behaviors.hide().then((r) {
        expect(mw.dom_element.style.display, equals("none"));
      });
    });

    test("hides the close button", () {
      expect(mw.findPart("close"), isNot(isNull));
      behaviors.hideCloseButton();
      expect(mw.findPart("close"), isNull);
    });

  });

}
