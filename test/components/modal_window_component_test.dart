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

class MockModalWindowComponentBehaviors extends Mock implements ModalWindowComponentBehaviors {}

void main() {

  var mw, root, behaviors;

  setUp(() {
    root = createComponent("RootComponent", el: document.body);
    var el = createModalWindowElement();
    el.attributes["data-component-template"] = "ModalWindowComponent";
    document.body.append(el);
  });

  group("ModalWindowComponent", () {

    group("initialization", () {

      test("displays a simple text as content", () {
        mw = new ModalWindowComponent("hello world");
        root.addChild(mw);
        expect(mw.content_el.text, equals("hello world"));
      });

      test("appends HtmlElement to content_el", () {
        var content_el = new DivElement();
        mw = new ModalWindowComponent(content_el);
        root.addChild(mw);
        expect(mw.content_el.children[0], equals(content_el));
      });

      test("appends child component's dom_element to content_el", () {
        var content_component = createComponent("Component");
        mw = new ModalWindowComponent(content_component);
        root.addChild(mw);
        expect(mw.content_el.children[0], equals(content_component.dom_element));
        expect(mw.children[0], equals(content_component));
      });
      
    });

    group("hiding", () {

      group("when close_button is clicked", () {

        test("it hides the modal window if #show_close_button is true", () {
          mw = createModalWindowComponent(root: root);
          mw.findPart("close").click();
          verify(mw.behavior_instances[0].hide());
        });

        test("it does nothing if #show_close_button is false", () {
          mw = createModalWindowComponent(root: root, attrs: { "show_close_button" : false });
          mw.findPart("close").click();
          verify(mw.behavior_instances[0].show());
          verify(mw.behavior_instances[0].hideCloseButton());
          verifyNoMoreInteractions(mw.behavior_instances[0]);
        });

      });

      group("when when background is clicked", () {

        test("it hides the modal window if #close_on_background_click is true", () {
          mw = createModalWindowComponent(root: root);
          mw.findPart("background").click();
          verify(mw.behavior_instances[0].hide());
        });

        test("it does nothing if #close_on_background_click is false", () {
          mw = createModalWindowComponent(root: root, attrs: { "close_on_background_click" : false });
          mw.findPart("background").click();
          verify(mw.behavior_instances[0].show());
          verifyNoMoreInteractions(mw.behavior_instances[0]);
        });

      });

      group("when ESC is pressed", () {

        new_key_event(code, target) {
          return new KeyEventMock(type: 'keydown', keyCode: code, target: target);
        }

        test("it hides the modal window if #close_on_escape is true", () {
          mw = createModalWindowComponent(root: root);
          mw.prvt_processKeyDownEvent(new_key_event(KeyCode.ESC, mw.dom_element));
          verify(mw.behavior_instances[0].hide());
        });

        test("it does nothing if #close_on_escape is false", () {
          mw = createModalWindowComponent(root: root, attrs: { "close_on_escape" : false });
          mw.prvt_processKeyDownEvent(new_key_event(KeyCode.ESC, mw.dom_element));
          verify(mw.behavior_instances[0].show());
          verifyNoMoreInteractions(mw.behavior_instances[0]);
        });

      });
      
    });

  });

}
