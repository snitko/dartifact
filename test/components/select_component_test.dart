import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import "dart:async";
import '../../lib/dartifact.dart';
part '../../lib/behaviors/select_component_behaviors.dart';
part '../../lib/components/select_component.dart';
part '../../lib/test_helpers/component_test_helpers.dart';

@TestOn("browser")

class MySelectComponentBehaviors extends Mock {
  MySelectComponentBehaviors(Component c) {}
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MySelectComponent extends SelectComponent {
  List behaviors = [MySelectComponentBehaviors];
  var http_request_completer;
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

class MyParentComponent extends Component {
  List events_history = [];
  MyParentComponent() {
    this.dom_element = new DivElement();
    event_handlers.add(event: 'change', role: 'select', handler: (self,caller) {
      self.events_history.add("'change' event on select");
    });
  }
}

void main() {

  var select_el;
  var select_comp;
  var behaviors;
  var option_els = [];

  setUp(() {
    select_el   = new DivElement();
    select_comp = new MySelectComponent();
    var options_container = new DivElement();
    options_container.attributes["data-component-part"] = "options_container";
    select_el.append(options_container);

    select_comp.dom_element = select_el;
    select_comp.afterInitialize();
    select_comp.ignore_misbehavior = false;
    behaviors = select_comp.behavior_instances[0];

    ["option_1", "option_2", "option_3", "option_4", "option_5"].forEach((o) {
      select_comp.options[o] = o.replaceAll('_', ' ');
    });
    select_comp.event_locks = [];

  });

  createOptionsInDom() {
    var option_template_el = new DivElement();
    option_template_el.attributes["data-component-part"] = "option_template";
    select_el.append(option_template_el);
    ["option_1", "option_2", "option_3", "option_4", "option_5"].forEach((o) {
      var option = new DivElement();
      option.attributes["data-component-part"] = "option";
      option.attributes["data-option-value"]   = o;
      option.text = o.replaceAll('_', '');
      select_el.append(option);
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
      select_comp.options = new LinkedHashMap();
      createOptionsInDom();
      expect(select_comp.options.keys, equals([]));
      select_comp.readOptionsFromDom();
      expect(select_comp.options.keys, equals(["option_1", "option_2", "option_3", "option_4", "option_5"]));
    });

    test("writes option input and display values to DOM", () {
      var option_template = new DivElement();
      option_template.attributes["data-component-part"] = "option_template";
      select_el.append(option_template);

      select_comp.options = new LinkedHashMap();
      select_comp.options["option_1"] = "option 1";
      select_comp.options["option_2"] = "option 2";
      select_comp.updateOptionsInDom();

      var option_els = select_comp.findAllParts("option");
      expect(option_els[0].attributes["data-option-value"], equals("option_1"));
      expect(option_els[0].text, equals("option 1"));
      expect(option_els[1].attributes["data-option-value"], equals("option_2"));
      expect(option_els[1].text, equals("option 2"));
    });

    test("sets display value and focused option using the input value", () {
      select_comp.setValueByInputValue("option_3");
      expect(select_comp.display_value,     equals("option 3"));
      expect(select_comp.focused_option_id, equals(2));
    });

    test("sets display value and focused option to null if input value is null", () {
      select_comp.setValueByInputValue("null");
      expect(select_comp.display_value,     isEmpty);
      expect(select_comp.focused_option_id, isNull);
    });

    test("publishes a 'change' event after setting a new value", () {
      select_comp.roles = ["select"];
      var parent = new MyParentComponent();
      parent.addChild(select_comp);
      select_comp.setValueByInputValue("option_3");
      expect(parent.events_history[0], equals("'change' event on select"));
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

    test("fetches options from a remote server", () {
      createOptionsInDom();
      select_comp.fetch_url = "/locations";
      select_comp.fetchOptions();
      select_comp.http_request_completer.future.then((response) {
        expect(select_comp.options.keys, equals(["hello"]));
      });
      select_comp.http_request_completer.complete("{ \"hello\": \"world\"}");
    });
    
    test("re-assigns native click events for newly fetched options in DOM", () {
      createOptionsInDom();
      select_comp.fetch_url = "/locations";
      select_comp.fetchOptions();
      select_comp.http_request_completer.future.then((response) {
        var first_option = select_comp.findAllParts("option").first;
        first_option.click();
        expect(select_comp.input_value, equals("hello"));
        expect(select_comp.display_value, equals("world"));
      });
      select_comp.http_request_completer.complete("{ \"hello\": \"world\"}");
    });

    test("assigns options an additional data that comes from fetched json", () {
      createOptionsInDom();
      select_comp.fetch_url = "/locations";
      select_comp.fetchOptions();
      select_comp.http_request_completer.future.then((response) {
        expect(select_comp.options_data["hello"], equals({ "some_numbers": [1,2,3]}));
      });
      select_comp.http_request_completer.complete("{ \"hello\": { \"display_value\": \"world\", \"some_numbers\": [1,2,3]}}");
      
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
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.ENTER));
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.SPACE));
        verify(behaviors.toggle()).called(2);
      });

      test("sets new value after pressing enter/space on one of the options, closes the select", () {
        select_comp.opened = true;
        select_comp.focused_option = "option_1";
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.ENTER));
        expect(select_comp.input_value, equals("option_1"));
        verify(behaviors.toggle()).called(1);
      });

      test("sets previous option as value after hitting UP", () {
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.UP));
        expect(select_comp.input_value, equals("option_5"));
      });

      test("sets next option as value after hitting DOWN", () {
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.DOWN));
        expect(select_comp.input_value, equals("option_1"));
      });

      test("sets previous option as focused after hitting UP", () {
        select_comp.opened = true;
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.UP));
        expect(select_comp.input_value, equals(null));
        expect(select_comp.focused_option, equals("option_5"));
      });

      test("sets next option as focused after hitting DOWN", () {
        select_comp.opened = true;
        select_comp.prvt_processKeyDownEvent(new_key_event(KeyCode.DOWN));
        expect(select_comp.input_value, equals(null));
        expect(select_comp.focused_option, equals("option_1"));
      });

    });

  });

}
