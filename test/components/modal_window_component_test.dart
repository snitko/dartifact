import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/modal_window_component.dart';
part '../../lib/behaviors/modal_window_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/modal_window_component_test_helpers.dart';

@TestOn("browser")

class MockHintComponentBehaviors extends Mock implements HintComponentBehaviors {}

void main() {

  var mw;

  setUp(() {
    // create a template
  });

  group("ModalWindowComponent", () {

    group("initialization", () {

      test("displays a simple text as content", () {
      });

      test("appends HtmlElement to content_el", () {
      });

      test("appends child component's dom_element to content_el", () {
      });
      
    });

    group("hiding", () {

      test("hides when close_button is clicked if button is visible", () {
      });

      test("hides when background is clicked if #close_on_background_click is set to true", () {
      });

      test("hides when background ESC is pressed if #close_on_escape is set to true", () {
      });
      
    });

  });

}
