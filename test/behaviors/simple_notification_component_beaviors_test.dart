import "package:test/test.dart";
import "dart:html";
import '../../lib/nest_ui.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'package:mockito/mockito.dart';

part '../../lib/test_helpers/component_test_helpers.dart';
part '../../lib/components/simple_notification_component.dart';
part '../../lib/behaviors/simple_notification_component_behaviors.dart';
part '../../lib/test_helpers/simple_notification_component_test_helpers.dart';

@TestOn("browser")

void main() {

  var root, sn, behaviors, container;

  group("SimpleNotificationComponentBehaviors", () {

    setUp(() {
      container = createDomEl("", attrs: { "id" : "simple_notifications_container" });
      document.body.append(container);
      root = createComponent("RootComponent", el: document.body, and: (c) {
        return [createSimpleNotificationElement(attrs: { "data-autohide-delay" : "0" })];
      });
      sn = root.children.first;
      behaviors = sn.behavior_instances.first;
      behaviors.show_hide_animation_speed = 0;
      sn.dom_element.style.display = "none";
    });

    group("on show", () {

      test("appends itself to the simple_notitifications container and becomes visible", () {
        var f = behaviors.show();
        f.then((r) {
          expect(sn.dom_element.style.display, equals("block"));
          expect(container.children.first, equals(sn.dom_element));
        });
        expect(f, completes);
      });

    });

    group("on hide", () {

      test("hides, then removes the dom_element from the DOM", () {
        var f1 = behaviors.show();
        var f2;
        f1.then((r1) {
          f2 = behaviors.hide();
          f2.then((r2) => expect(container.children, isEmpty));
          expect(f2, completes);
        });
        expect(f1, completes);
      });

    });

  });

}
