import "package:test/test.dart";
import 'package:mockito/mockito.dart';
import "dart:html";
import '../../lib/nest_ui.dart';

part '../../lib/components/select_component.dart';
part '../../lib/behaviors/select_component_behaviors.dart';

@TestOn("browser")

void main() {

  var select_el;
  var select_comp;
  var behaviors;
  var options_container;
  var selectbox;
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
    selectbox.attributes["data-component-part"] = "selectbox";
    select_el.append(selectbox);
    createOptionsInDom();

    select_comp = new SelectComponent();
    select_comp.dom_element = select_el;
    select_comp.afterInitialize();
    behaviors = select_comp.behavior_instances[0];
  });

  group("SelectComponentBeahviors", () {

    test("makes the option container appear when opening", () {
      behaviors.open();
      expect(options_container.style.display, equals('block'));
    });
    
    test("makes the option container disappear when closing", () {
      behaviors.open();
      behaviors.close();
      expect(options_container.style.display, equals('none'));
    });

    test("toggles the appearance or disappearance of the options container on open/close", () {
      behaviors.toggle();
      expect(options_container.style.display, equals('block'));
      select_comp.opened = true;
      behaviors.toggle();
      expect(options_container.style.display, equals('none'));
    });
    
    test("marks currently focused option DOM element with a .focused class", () {
      select_comp.focused_option = "option_3";
      behaviors.focusCurrentOption();
      expect(option_els[2].classes, contains('focused'));
    });

    group("ajax indicator", () {

      var ai;

      setUp(() {
        ai = new ImageElement();
        ai.classes.add("ajaxIndicator");
        ai.style.display = "none";
        select_el.append(ai);
      });

      test("is shown", () {
        behaviors.showAjaxIndicator();
        expect(ai.style.display, equals("inline"));
      });

      test("is hidden", () {
        ai.style.display = "inline";
        behaviors.hideAjaxIndicator();
        expect(ai.style.display, equals("none"));
      });
      
    });

    group("no options found warning", () {

      var warning;

      setUp(() {
        warning = new DivElement();
        warning.classes.add("noOptionsFoundMessage");
        warning.style.display = "none";
        select_el.append(warning);
      });

      test("is shown", () {
        behaviors.showNoOptionsFound();
        expect(warning.style.display, equals("block"));
      });

      test("is hidden", () {
        warning.style.display = "block";
        behaviors.hideNoOptionsFound();
        expect(warning.style.display, equals("none"));
      });
      
    });
    
  });

}
