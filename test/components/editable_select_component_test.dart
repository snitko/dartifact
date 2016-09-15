import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
part '../../lib/behaviors/select_component_behaviors.dart';
part '../../lib/components/select_component.dart';
part '../../lib/behaviors/editable_select_component_behaviors.dart';
part '../../lib/components/editable_select_component.dart';

@TestOn("browser")

class MyEditableSelectComponentBehaviors extends Mock {
  MyEditableSelectComponentBehaviors(Component c) {}
  noSuchMethod(i) => super.noSuchMethod(i);
}

class MyEditableSelectComponent extends EditableSelectComponent {
  int keypress_stack_timeout = 0;
  var http_request_completer;
  List behaviors = [MyEditableSelectComponentBehaviors];
  ajax_request(url) {
    http_request_completer = new Completer();
    return http_request_completer.future;
  }
}

class EditableSelectKeyEventMock {
  String type;
  int keyCode, charCode;
  var target;
  EditableSelectKeyEventMock({ type: null, keyCode: null, charCode: null, target: null }) {
    this.type     = type;
    this.keyCode  = keyCode;
    this.charCode = charCode;
    this.target   = target;
  }
  preventDefault() {}
}

void main() {

  var select_el;
  var input_el;
  var display_input_el;
  var select_comp;
  var behaviors;
  var option_els = [];

  createOptionsInDom() {
    var options_container_el = new DivElement();
    var option_template_el   = new DivElement();
    options_container_el.attributes["data-component-part"] = "options_container";
    option_template_el.attributes["data-component-part"]   = "option_template";
    select_el.append(options_container_el);
    select_el.append(option_template_el);

    ["a", "ab", "abc", "abcd", "abcde", "edcba"].forEach((o) {
      var option = new DivElement();
      option.attributes["data-component-part"] = "option";
      option.attributes["data-option-value"]   = o;
      option.text = o.replaceAll('_', '');
      options_container_el.append(option);
    });
  }

  setUp(() {
    select_el   = new DivElement();
    input_el    = new InputElement();
    display_input_el = new InputElement();
    select_comp = new MyEditableSelectComponent();
    select_comp.dom_element = select_el;
    input_el.attributes["data-component-part"]                 = "input";
    input_el.attributes["data-component-property"]             = "input_value";
    input_el.attributes["data-component-attribute-properties"] = "input_value:value";
    display_input_el.attributes["data-component-part"]         = "display_input";
    display_input_el.attributes["data-component-property"]     = "display_value";
    display_input_el.attributes["data-component-attribute-properties"] = "display_value:value";
    select_el.append(input_el);
    select_el.append(display_input_el);

    createOptionsInDom();
    select_comp.afterInitialize();
  });

  new_key_event(code) {
    return new EditableSelectKeyEventMock(type: 'keyup', keyCode: code, target: input_el);
  }

  group("EditableSelectComponent", () {

    test("fetches options from a remote server", () {
      select_comp.fetch_url = "/locations";
      select_comp.fetchOptions();
      select_comp.http_request_completer.future.then((response) {
        expect(select_comp.options.keys, equals(["hello"]));
      });
      select_comp.http_request_completer.complete("{ \"hello\": \"world\"}");
    });

    test("filters existing options", () {
      display_input_el.value = "ab";
      select_comp.filterOptions();
      expect(select_comp.options.keys, equals(["ab", "abc", "abcd", "abcde"]));
      display_input_el.value = "abcd";
      select_comp.filterOptions();
      expect(select_comp.options.keys, equals(["abcd", "abcde"]));
      display_input_el.value = "abcdef";
      select_comp.filterOptions();
      expect(select_comp.options.keys, isEmpty);
    });
    
    test("clears value from the input", () {
      display_input_el.value = "ab";
      select_comp.prvt_processInputKeyUpEvent(new_key_event(KeyCode.ENTER));
      expect(input_el.value, equals(""));
    });

    test("re-creates even listeners for options when they're loaded or filtered", () {
      display_input_el.value = "ab";
      select_comp.filterOptions();
      select_comp.opened = true;
      select_comp.findAllParts("option").last.click();
      expect(select_comp.input_value, equals("abcde"));
    });

    test("manipulates fetch_url params", () {
      select_comp.fetch_url = "/locations";
      select_comp.updateFetchUrlParams({ "hello" : "world" });
      expect(select_comp.fetch_url, equals("/locations?hello=world"));
      select_comp.updateFetchUrlParams({ "hello" : "hi" });
      expect(select_comp.fetch_url, equals("/locations?hello=hi"));
      select_comp.updateFetchUrlParams({ "param2" : "value2" });
      expect(select_comp.fetch_url, equals("/locations?hello=hi&param2=value2"));
      select_comp.updateFetchUrlParams({ "hello" : "world" });
      expect(select_comp.fetch_url, equals("/locations?hello=world&param2=value2"));
      select_comp.updateFetchUrlParams({ "hello" : null });
      expect(select_comp.fetch_url, equals("/locations?param2=value2"));
    });

    test("sets custom value to input_value if no corresponding input_value is found in options", () {
      select_comp.allow_custom_value = true;
      display_input_el.value = "custom value";
      select_comp.prvt_processInputKeyUpEvent(new_key_event(KeyCode.ENTER));
      expect(select_comp.input_value, equals("custom value"));
    });

    test("resets the value to the previous one if on ESC keypress or on external click", () {
      select_comp.allow_custom_value = true;
      select_comp.input_value = "ab";

      select_comp.findPart("display_input").value = "abc";
      select_comp.externalClickCallback();
      expect(select_comp.input_value, equals("ab"));
      expect(select_comp.display_value, equals("ab"));
      expect(select_comp.current_input_value, equals("ab"));

      select_comp.findPart("display_input").value = "abc";
      select_comp.prvt_processInputKeyUpEvent(new_key_event(KeyCode.ESC));
      expect(select_comp.input_value, equals("ab"));
      expect(select_comp.display_value, equals("ab"));
      expect(select_comp.current_input_value, equals("ab"));
    });

    test("sets custom value when it's allowed", () {
      select_comp.allow_custom_value = true;
      select_comp.findPart("display_input").value = "hello world";
      select_comp.prvt_processInputKeyUpEvent(new_key_event(KeyCode.ENTER));
      expect(select_comp.input_value, equals("hello world"));
      expect(select_comp.display_value, equals("hello world"));
    });

  });

}
