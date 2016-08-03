import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import '../../lib/nest_ui.dart';

part '../../lib/components/select_component.dart';

@TestOn("browser")

class SelectComponentBehaviors extends Mock {
  SelectComponentBehaviors(Component c) {}
  noSuchMethod(i) => super.noSuchMethod(i);
}

class KeyEventMock {
  String type;
  int keyCode, charCode;
  var target;
  KeyEventMock({ type: null, keyCode: null, charCode: null, target: null }) {
    this.type     = type;
    this.keyCode  = keyCode;
    this.charCode = charCode;
    this.target   = target;
  }
  preventDefault() {}
}

void main() {

  var select_el;
  var select_comp;
  var behaviors;
  var option_els = [];

  setUp(() {
    select_el   = new DivElement();
    select_comp = new SelectComponent();
    select_comp.dom_element = select_el;
    select_comp.afterInitialize();
    select_comp.ignore_misbehavior = false;
    behaviors = select_comp.behavior_instances[0];

    ["option_1", "option_2", "option_3", "option_4", "option_5"].forEach((o) {
      select_comp.options[o] = o.replaceAll('_', ' ');
    });

  });

  createOptionsInDom() {
    ["option_1", "option_2", "option_3", "option_4", "option_5"].forEach((o) {
      var option = new DivElement();
      option.attributes["data-component-part"] = "option";
      option.attributes["data-option-value"]   = o;
      option.text = o.replaceAll('_', '');
      select_comp.dom_element.append(option);
      option_els.add(option);
    });
  }

  group("SelectComponent", () {

    test("returns focused option id as per its order in #options Map", () {
      select_comp.focused_option = "option_1";
      expect(select_comp.focused_option_id, equals(0));
      select_comp.focused_option = "option_2";
      expect(select_comp.focused_option_id, equals(1));
    });

    test("sets focused option as current (if any focused) and toggles open/close", () {
      select_comp.opened = true;
      select_comp.setFocusedAndToggle();
      verify(behaviors.toggle()).called(1);
    });

    test("reads option input and display values from DOM", () {
      select_comp.options = new SplayTreeMap();
      createOptionsInDom();
      expect(select_comp.options.keys, equals([]));
      select_comp.readOptionsFromDom();
      expect(select_comp.options.keys, equals(["option_1", "option_2", "option_3", "option_4", "option_5"]));
      
    });

    test("sets display value and focused option using the input value", () {
      select_comp.setValueByInputValue("option_3");
      expect(select_comp.display_value,     equals("option 3"));
      expect(select_comp.focused_option_id, equals(2));
    });

    test("sets display value and focused option to null if input value is null", () {
      select_comp.setValueByInputValue("null");
      expect(select_comp.display_value,     isNull);
      expect(select_comp.focused_option_id, isNull);
    });

    test("focuses on previous option", () {
      select_comp.focusPrevOption();
      expect(select_comp.focused_option, equals("option_5"));
      select_comp.focusPrevOption();
      expect(select_comp.focused_option, equals("option_4"));
      verify(behaviors.focusCurrentOption()).called(2);
    });

    test("focuses on next option", () {
      select_comp.focusNextOption();
      expect(select_comp.focused_option, equals("option_1"));
      select_comp.focusNextOption();
      expect(select_comp.focused_option, equals("option_2"));
      verify(behaviors.focusCurrentOption()).called(2);
    });

    test("sets value to the value preceeding current value", () {
      select_comp.setPrevValue();
      expect(select_comp.input_value, equals("option_5"));
      select_comp.setPrevValue();
      expect(select_comp.input_value, equals("option_4"));
    });

    test("sets value to the value following current value", () {
      select_comp.setNextValue();
      expect(select_comp.input_value, equals("option_1"));
      select_comp.setNextValue();
      expect(select_comp.input_value, equals("option_2"));
    });

    test("gets a value preceeding current value", () {
      expect(select_comp.getPrevValue(null), equals("option_5"));
      expect(select_comp.getPrevValue("option_1"), equals("option_5"));
      expect(select_comp.getPrevValue("option_2"), equals("option_1"));
    });

    test("gets a value following current value", () {
      expect(select_comp.getNextValue(null), equals("option_1"));
      expect(select_comp.getNextValue("option_1"), equals("option_2"));
      expect(select_comp.getNextValue("option_5"), equals("option_1"));
    });
    

    group("character keypresses", () {
      
      test("updates keypress_stack with a new character", () {
        for(var i=0; i < 3; i++)
          select_comp.updateKeypressStackWithChar("a");
        expect(select_comp.keypress_stack, equals("aaa"));
      });

      test("sets value from keypress_stack", () {
        select_comp.updateKeypressStackWithChar("o");
        select_comp.updateKeypressStackWithChar("p");
        select_comp.updateKeypressStackWithChar("t");
        select_comp.setValueFromKeypressStack();
        expect(select_comp.input_value, equals("option_1"));
      });

      test("resets keypress_stack after 1 second", () {
        for(var i=0; i < 3; i++)
          select_comp.updateKeypressStackWithChar("a");
        select_comp.keypress_stack_last_updated -= 1500;
        select_comp.updateKeypressStackWithChar("b");
        expect(select_comp.keypress_stack, equals("b"));
      });
    });

    group("navigational keypresses", () {

      new_key_event(code) {
        return new KeyEventMock(type: 'keydown', keyCode: code, target: select_el);
      }

      test("invokes toggle behavior on enter/space", () {
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.ENTER));
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.SPACE));
        verify(behaviors.toggle()).called(2);
      });

      test("sets new value after pressing enter/space on one of the options, closes the select", () {
        select_comp.opened = true;
        select_comp.focused_option = "option_1";
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.ENTER));
        expect(select_comp.input_value, equals("option_1"));
        verify(behaviors.toggle()).called(1);
      });

      test("sets previous option as value after hitting UP", () {
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.UP));
        expect(select_comp.input_value, equals("option_5"));
      });

      test("sets next option as value after hitting DOWN", () {
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.DOWN));
        expect(select_comp.input_value, equals("option_1"));
      });

      test("sets previous option as focused after hitting UP", () {
        select_comp.opened = true;
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.UP));
        expect(select_comp.input_value, equals(null));
        expect(select_comp.focused_option, equals("option_5"));
      });

      test("sets next option as focused after hitting DOWN", () {
        select_comp.opened = true;
        select_comp.prvt_processKeyEvent(new_key_event(KeyCode.DOWN));
        expect(select_comp.input_value, equals(null));
        expect(select_comp.focused_option, equals("option_1"));
      });

    });

  });

}
