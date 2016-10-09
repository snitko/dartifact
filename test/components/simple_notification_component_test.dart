import "package:test/test.dart";
import "dart:html";
import "dart:async";
import '../../lib/nest_ui.dart';
import 'package:mockito/mockito.dart';

part '../../lib/components/simple_notification_component.dart';
part '../../lib/behaviors/simple_notification_component_behaviors.dart';
part '../../lib/test_helpers/simple_notification_component_test_helpers.dart';

part '../../lib/test_helpers/component_test_helpers.dart';

@TestOn("browser")

class MockSimpleNotificationComponentBehaviors extends Mock implements SimpleNotificationComponentBehaviors {}

void main() {

  var root, sn, behavior;

  group("SimpleNotificationComponent", () {

    setUp((){
      document.body.append(createDomEl("", attrs: { "id" : "simple_notifications_container" }));
      root = createComponent("RootComponent", el: document.body, and: (c) {
        return [createSimpleNotificationElement(attrs: { "data-autohide-delay" : "0" })];
      });
      sn = root.children.first;
      behavior = new MockSimpleNotificationComponentBehaviors();
      sn.behavior_instances = [behavior];
      sn.ignore_misbehavior = false;
    });

    test("shows automatically upon initialization", () {
      sn.show();
      expect(sn.visible, equals(true));
      verify(behavior.show());
    });

    test("hides itself automatically after a autodisplay_delay seconds pass", () {
      sn.autohide_future.then((r) {
        expect(sn.visible, isFalse);
        verify(behavior.hide());
      });
    });

    test("doesn't allow to hide itself if it's permanent", () {
    });

    test("hides the itself when 'close' part is clicked", () {
    });

    test("removes itself from it's parent children's collection on hide", () {
    });

  });

}
