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

  var mw;

  group("ModalWindowComponentBehaviors", () {

    test("displays dom_element on show()", () {
    });

    test("hides dom_element on hide() and removes itself from RootComponent", () {
    });

  });

}
