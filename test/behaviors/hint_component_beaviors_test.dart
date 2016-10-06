import "package:test/test.dart";
import "dart:html";
import '../../lib/nest_ui.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'package:mockito/mockito.dart';

part '../../lib/components/hint_component.dart';
part '../../lib/behaviors/hint_component_behaviors.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/test_helpers/hint_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var hint, behaviors;

  group("HintComponentBehaviors", () {

    setUp(() {
      behaviors = new HintComponentBehaviors();
    });

    test("positions itself above the anchor, slightly to the left when enough space above and to the left", () {
    });

    test("positions itself below the anchor, slightly to the left when not enough space above, but enough to the left", () {
    });

    test("positions itself above the anchor, slightly to the right when enough space above, but not enough to the left", () {
    });

    test("positions itself below the anchor, slightly to the right when not enough space above and to the left", () {
    });
    
  });

}
