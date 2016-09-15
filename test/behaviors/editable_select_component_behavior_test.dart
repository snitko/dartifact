import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import '../../lib/nest_ui.dart';

part '../../lib/components/select_component.dart';
part '../../lib/behaviors/select_component_behaviors.dart';
part '../../lib/components/editable_select_component.dart';
part '../../lib/behaviors/editable_select_component_behaviors.dart';

@TestOn("browser")

void main() {

  var select_el, select_comp, behaviors, options_container, selectbox, input;
  var option_els = [];

  createOptionsInDom() {

    options_container = new DivElement();
    options_container.attributes["data-component-part"] = "options_container";
    options_container.style.display = 'none';
    select_el.append(options_container);

    ["option_1", "option_2", "option_3", "option_4", "option_5"].forEach((o) {
      var option = new DivElement();
      option.attributes["data-component-part"] = "option";
      option.attributes["data-option-value"]   = o;
      option.text = o.replaceAll('_', '');
      options_container.append(option);
    });
    option_els = options_container.children;
  }

  setUp(() {
    select_el   = new DivElement();
    selectbox   = new DivElement();
    input       = new InputElement();
    input.attributes["data-component-part"] = "display_input";
    input.attributes["placeholder"] = "Start typing...";
    selectbox.attributes["data-component-part"] = "selectbox";
    select_el.append(selectbox);
    select_el.append(input);
    createOptionsInDom();

    select_comp = new EditableSelectComponent();
    select_comp.dom_element = select_el;
    select_comp.afterInitialize();
    behaviors = select_comp.behavior_instances[1];
  });

  group("EditableSelectComponentBeahviors", () {

    group("disable/enable", () {

      test("disables the selectbox and removes the placholder", () {
        behaviors.disable();
        expect(input.attributes["disabled"], equals("disabled"));
        expect(input.attributes["placeholder"], isEmpty);
      });

      test("disables the selectbox and removes the placholder", () {
        behaviors.disable();
        behaviors.enable();
        expect(input.attributes["disabled"], isNull);
        expect(input.attributes["placeholder"], "Start typing...");
      });
      
    });

  });

}
