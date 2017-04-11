import "package:test/test.dart";
import "dart:html";
import '../../lib/dartifact.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'package:mockito/mockito.dart';

part '../../lib/components/hint_component.dart';
part '../../lib/behaviors/hint_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/hint_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var hint, anchor, parent, behavior;

  group("HintComponentBehaviors", () {

    setUp(() {
      var hint_and_parent = createHintComponentWithParentAndAnchor();
      hint                = hint_and_parent["hint"];
      parent              = hint_and_parent["parent"];
      anchor              = hint_and_parent["anchor"];
      behavior            = hint.behavior_instances[0];
      behavior.pos.base_offset = { "x" : 0, "y" : 0 };
      document.body.attributes["style"]    = "width: 1000px; height: 1000px";
      hint.dom_element.attributes["style"] = "width: 22px; height: 11px";
      anchor.attributes["style"]           = "width: 10px; height: 10px; position: absolute;";
      document.body.append(parent.dom_element);
    });

    test("positions itself above the anchor, on the right side when enough space above and to the right", () {
      anchor.style.top  = "30px";
      anchor.style.left = "10px";
      behavior.show();
      expect(hint.dom_element.style.top, equals("19px"));
      expect(hint.dom_element.style.left, equals("20px"));
      expect(hint.dom_element.classes, contains("arrowBottomLeft"));
    });

    test("positions itself above the anchor, on the left side when enough space above, but NOT enough on the right", () {
      anchor.style.top  = "30px";
      anchor.style.left = "990px";
      behavior.show();
      expect(hint.dom_element.style.top, equals("19px"));
      expect(hint.dom_element.style.left, equals("968px"));
      expect(hint.dom_element.classes, contains("arrowBottomRight"));
    });
    
    test("positions itself below the anchor, on the right side when NOT enough space above, but enough on the right", () {
      anchor.style.top  = "0px";
      anchor.style.left = "10px";
      behavior.show();
      expect(hint.dom_element.style.top, equals("10px"));
      expect(hint.dom_element.style.left, equals("20px"));
      expect(hint.dom_element.classes, contains("arrowTopLeft"));
    });

    test("positions itself below the anchor, on the left side when NOT enough space above and NOT enough on the right", () {
      anchor.style.top  = "0px";
      anchor.style.left = "990px";
      behavior.show();
      expect(hint.dom_element.style.top, equals("10px"));
      expect(hint.dom_element.style.left, equals("968px"));
      expect(hint.dom_element.classes, contains("arrowTopRight"));
    });

  });

}
