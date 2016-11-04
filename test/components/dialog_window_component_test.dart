import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/modal_window_component.dart';
part '../../lib/components/dialog_window_component.dart';
part '../../lib/behaviors/modal_window_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/modal_window_component_test_helpers.dart';

@TestOn("browser")

class MockModalWindowComponentBehaviors extends Mock implements ModalWindowComponentBehaviors {}

void main() {

  var dw, root, behaviors;

  setUp(() {
    root = createComponent("RootComponent", el: document.body);
    var el = createModalWindowElement();
    el.attributes["data-component-template"] = "DialogWindowComponent";
    document.body.append(el);
  });

  group("DialogWindowComponent", () {

    test("creates a new dialog window", () {
      dw = new DialogWindowComponent("Do you event lift?");
    });

  });

}
