import '../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";
part '../lib/test_helpers/component_test_helpers.dart';

@TestOn("browser")

class TestComponentBehaviors1 extends BaseComponentBehaviors {
  Component component;
  TestComponentBehaviors1(Component c) : super(c) { this.component = c; }
  say_hello() => this.component.behaviors_history.add("TestComponentBehaviors1 says hello");
  say_bye()   => this.component.behaviors_history.add("TestComponentBehaviors1 says bye");
}

class TestComponentBehaviors2 extends BaseComponentBehaviors {
  Component component;
  TestComponentBehaviors2(Component c) : super(c) { this.component = c; }
  say_hello() => this.component.behaviors_history.add("TestComponentBehaviors2 says hello");
}

class TestComponent extends Component {
  List behaviors_history = [];
  List behaviors = [BaseComponentBehaviors, TestComponentBehaviors1, TestComponentBehaviors2];
}

main() {

  var c, el;

  setUp(() {
    c = createComponent("TestComponent");
    el = c.dom_element;
  });

  group("component behaviors", () {

    test("it invokes behaviors in reversed order", () {
      c.behave("say_hello");
      c.behave("say_bye");
      expect(c.behaviors_history, equals(["TestComponentBehaviors2 says hello","TestComponentBehaviors1 says bye" ]));
    });

    group("visibility", () {
      
      test("hides an element", () {
        c.behave('hide');
        expect(el.style.display, equals('none'));
      });

      test("shows an element", () {
        c.dom_element.style.display="none";
        c.behave('show');
        expect(el.style.display, equals('block'));
      });

      test("shows an element with the specified display value", () {
        c.dom_element.style.display="none";
        c.dom_element.attributes['data-component-display-value'] = 'inline-block';
        c.behave('show');
        expect(el.style.display, equals('inline-block'));
      });

      test("toggles visibility", () {
        c.behave('toggleDisplay');
        expect(el.style.display, equals('none'));
        c.behave('toggleDisplay');
        expect(el.style.display, equals('block'));
      });

    });

    group("locking/unlocking", () {
      
      test("adds 'locked' class to a locked element", () {
        c.behave('lock');
        expect(el.classes, contains('locked'));
      });

      test("removes 'locked' class from an unlocked element", () {
        c.dom_element.classes.add("locked");
        c.behave('unlock');
        expect(el.classes, isNot(contains('locked')));
      });

      test("toggles between locked and unlocked by adding/removing 'locked' class", () {
        c.behave('toggleLock');
        expect(el.classes, contains('locked'));
        c.behave('toggleLock');
        expect(el.classes, isNot(contains('locked')));
      });

    });

    group("disabling/enabling", () {
      
      test("adds 'disabled' class and attribute to a locked element", () {
        c.behave('disable');
        expect(el.classes,    contains('disabled'));
        expect(el.attributes, contains('disabled'));
      });

      test("removes 'disabled' class and attribute from a locked element", () {
        c.dom_element.classes.add("disabled");
        c.dom_element.setAttribute("disabled", "disabled");
        c.behave('enable');
        expect(el.classes,    isNot(contains('disabled')));
        expect(el.attributes, isNot(contains('disabled')));
      });

      test("toggles between locked and unlocked by adding/removing .locked class", () {
        c.behave('disable');
        expect(el.classes, contains('disabled'));
        expect(el.attributes, contains('disabled'));
        c.behave('enable');
        expect(el.classes, isNot(contains('disabled')));
        expect(el.attributes, isNot(contains('disabled')));
      });

    });
    
  });

}
