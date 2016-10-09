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

  var root, sn, behavior;

  group("SimpleNotificationComponentBehaviors", () {

    setUp(() {
      document.body.append(createDomEl("", attrs: { "id" : "simple_notifications_container" }));
      root = createComponent("RootComponent", el: document.body, and: (c) {
        return [createSimpleNotificationElement(attrs: { "data-autohide-delay" : "0" })];
      });
      sn = root.children.first;
    });

    group("on show", () {

      test("appends itself to the simple_notitifications container and becomes visible", () {
        
      });

      test("places itself below the last notification", () {
        
      });

    });

    group("on hide", () {

      test("hides, then removes the dom_element from the DOM", () {
        
      });
      
      test("makes all other existing simple_notifications in the container adjust their positions", () {
        
      });

    });

  });

}
