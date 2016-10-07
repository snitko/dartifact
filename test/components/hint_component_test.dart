import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'package:mockito/mockito.dart';

part '../../lib/components/hint_component.dart';
part '../../lib/behaviors/hint_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/hint_component_test_helpers.dart';

@TestOn("browser")

class MockHintComponentBehaviors extends Mock implements HintComponentBehaviors {}

void main() {

  var hint, parent, anchor, behavior;

  createTestHintComponent({attrs: null, anchor_type: "dom_element"}) {
    var hint_and_parent     = createHintComponentWithParentAndAnchor(attrs: attrs, anchor_type: anchor_type);
    hint                    = hint_and_parent["hint"];
    parent                  = hint_and_parent["parent"];
    anchor                  = hint_and_parent["anchor"];
    behavior                = new MockHintComponentBehaviors();
    hint.behavior_instances = [behavior];
    hint.ignore_misbehavior = false;
  }

  setUp(() {
    cookie.remove("hint_test_hint");
    cookie.remove("hint_test_hint_never_show_again");
    createTestHintComponent();
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
        expect(hint.anchor_object.attributes["data-component-property"], equals("hint_anchor"));
      });

      test("finds anchor element in his parents DOM el descendants using HTML id attribute", () {
        hint.anchor = "hint_anchor";
        parent.dom_element.append(
          anchor = createDomEl(null, attrs: { "id" : "hint_anchor" })
        );
        expect(hint.anchor_object.attributes["id"], equals("hint_anchor"));
      });

      test("finds anchor element in his parent's children", () {
        hint.anchor = "role:hint_anchor";
        anchor = createComponent("Component", roles: "hint_anchor");
        parent.addChild(anchor);
        expect(hint.anchor_object, equals(anchor));
      });

      test("finds anchor element in his parent's child parts", () {
        hint.anchor = "role:hint_anchor:input";
        var anchor_component = createComponent("Component", roles: "hint_anchor", and: (el) {
          return [createDomEl("", part: "input")];
        });
        var anchor_el = anchor_component.findPart("input");
        parent.addChild(anchor_component);
        expect(hint.anchor_object, equals(anchor_el));
      });
      
    });

    group("creating events", () {

      test("creates an event handler triggering show for a native event on an anchor when it's an HTML element", () {
        hint.display_limit = 1;
        anchor.click();
        expect(hint.visible, equals(true));
        hint.visible = false;
        anchor.click();
        expect(hint.visible, equals(false));
      });

      test("creates an event handler triggering forced show for a native event on an anchor when it's an HTML element", () {
        hint.display_limit = 1;
        anchor.click();
        expect(hint.visible, equals(true));
        hint.visible = false;
        anchor.dispatchEvent(new Event("mouseup"));
        expect(hint.visible, equals(true));
      });

      group("for Components as hint anchors", () {

        setUp(() {
          createTestHintComponent(attrs: {
            "data-anchor"      : "role:hint_anchor",
            "data-hint-id"     : "test_hint",
            "data-show-events" : "change1",
            "data-force-show-events" : "change2"
          }, anchor_type: "component");
          anchor = hint.anchor_object;
        });

        test("creates an event handler triggering show for a component event on an anchor when it's a Component", () {
          hint.display_limit = 1;
          anchor.publishEvent("change1");
          expect(hint.visible, equals(true));
          hint.visible = false;
          anchor.publishEvent("change1");
          expect(hint.visible, equals(false));
        });

        test("creates an event handler triggering forced show for a component event on an anchor when it's a Component", () {
          hint.display_limit = 1;
          anchor.publishEvent("change1");
          expect(hint.visible, equals(true));
          hint.visible = false;
          anchor.publishEvent("change2");
          expect(hint.visible, equals(true));
        });

      });

    });

    test("updates cookie with a display limit incrementing it by 1", () {
      hint.display_limit = 2;
      hint.incrementDisplayLimit();
      expect(cookie.get("hint_${hint.hint_id}"), "1");
      hint.incrementDisplayLimit();
      expect(cookie.get("hint_${hint.hint_id}"), "2");
      hint.incrementDisplayLimit();
      expect(cookie.get("hint_${hint.hint_id}"), "2");
    });

    test("checks wether display limit is reached", () {
      hint.incrementDisplayLimit();
      expect(hint.isDisplayLimitReached, equals(false));
      hint.display_limit = 3;
      hint.incrementDisplayLimit();
      expect(hint.isDisplayLimitReached, equals(false));
      hint.incrementDisplayLimit();
      expect(hint.isDisplayLimitReached, equals(true));
    });

    test("calls the show behavior after a show event is invoked", () {
      anchor.click();
      verify(behavior.show());
      expect(hint.visible, isTrue);
    });

    test("calls the hide behavior and sets visible to false", () {
      hint.hide();
      verify(behavior.hide());
      expect(hint.visible, isFalse);
    });

    group("auto show/hide", () {

      setUp(() {
        createTestHintComponent(attrs: {
          "data-autoshow-delay" : "0",
          "data-autohide-delay" : "0"
        });
      });

      test("shows itself automatically after initialization", () {
        hint.autoshow_future.then((r) => expect(hint.visible, isTrue));
      });

      test("hides itself automatically after a autodisplay_delay seconds pass", () {
        hint.autoshow_future.then((r) {
          hint.autohide_future.then((r) => expect(hint.visible, isFalse));
        });
      });
      
    });

    group("closing", () {

      setUp(() {
        hint.visible = true;
      });

      test("closes the hint", () {
        hint.findPart("close_and_never_show").click();
        expect(hint.visible, isFalse);
        verify(behavior.hide());
      });

      test("closes and never shows the hint again", () {
        hint.findPart("close_and_never_show").click();
        expect(hint.visible, isFalse);
        verify(behavior.hide());
        hint.show();
        expect(hint.visible, isFalse);
      });
    
    });

  });

}
