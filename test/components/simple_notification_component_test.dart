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

  var root, sn, behaviors;

  group("SimpleNotificationComponent", () {

    setUp((){
      document.body.children.clear();
      document.body.append(createDomEl("", attrs: { "id" : "simple_notifications_container" }));
      root = createComponent("RootComponent", el: document.body, and: (c) {
        return [createSimpleNotificationElement(attrs: { "data-autohide-delay" : "0" })];
      });
      sn = root.children.first;
      behaviors = new MockSimpleNotificationComponentBehaviors();
      sn.behavior_instances = [behaviors];
      sn.ignore_misbehavior = false;
    });

    test("shows automatically upon initialization", () {
      sn.show();
      expect(sn.visible, equals(true));
      verify(behaviors.show());
    });

    test("hides itself automatically after a autodisplay_delay seconds pass", () {
      sn.autohide_future.then((r) {
        expect(sn.visible, isFalse);
        verify(behaviors.hide());
      });
    });

    test("hides itself when close button is clicked", () {
      sn.findPart("close").click();
      expect(sn.visible, isFalse);
    });

    test("doesn't allow to hide itself if it's permanent", () {
      sn.permanent = true;
      sn.findPart("close").click();
      expect(sn.visible, isTrue);
    });

    test("removes itself from it's parent children's collection on hide", () {
      expect(sn.parent.children, contains(sn));
      sn.hide();
      expect(sn.parent.children, isNot(contains(sn)));
    });

    test("doesn't show two notifications with identical messages", () {
      sn.message = "Hello world";
      var n = createSimpleNotificationComponent(roles: "simple_notification");
      n.message = "Hello world";
      root.addChild(n);
      expect(n.visible, equals(false));
    });

  });

}
