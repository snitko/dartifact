import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';

part '../../lib/components/hint_component.dart';
part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/hint_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var hint, parent, anchor;
  Component.app_library = "nest_ui";

  setUp(() {
    parent = createComponent("Component", and: (c) {
      hint = createHintComponent(and: (h) {
        h.anchor = "part:hint_anchor";
      });
      anchor = createDomEl(null, part: "hint_anchor");
      return [hint, anchor];
    });
    
  });

  group("HintComponent", () {

    group("finding anchor", () {

      test("finds anchor element in his parent's list of parts", () {
        // here we use the default value for anchor, which was set in setUp();
        expect(hint.anchor, equals("part:hint_anchor"));
        expect(hint.anchor_object, equals(anchor));
      });

      test("finds anchor element in his parent's list of properties", () {
        hint.anchor = "property:hint_anchor";
        parent.dom_element.append(
          anchor = createDomEl(null, attrs: { "data-component-property" : "hint_anchor" })
        );
        expect(hint.anchor_object, equals(anchor));
      });

      test("finds anchor element in his parents DOM el descendants using HTML id attribute", () {
        hint.anchor = "hint_anchor";
        parent.dom_element.append(
          anchor = createDomEl(null, attrs: { "id" : "hint_anchor" })
        );
        expect(hint.anchor_object, equals(anchor));
      });

      test("finds anchor element in his parent's children", () {
        hint.anchor = "role:hint_anchor";
        anchor = createComponent("Component", roles: "hint_anchor");
        parent.addChild(anchor);
        expect(hint.anchor_object, equals(anchor));
      });
      
    });



    test("creates an event handler for the anchor el", () {
    });

    test("updates cookie with a display limit", () {
    });

    test("checks wether disaply limit is reached", () {
      
    });
    
  });

}
