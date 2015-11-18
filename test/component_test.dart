import '../lib/nest_ui.dart';
import "package:test/test.dart";

@TestOn("browser")

void main() {

  var c;

  setUp(() {
    c = new Component();
  });

  group("Component", () {

    group("with children", () {

      test("adds child components", () {
        c.addChild(new Component());
        c.addChild(new Component());
        expect(c.children, everyElement(new isInstanceOf<Component>())); 
        expect(c.children.length, 2); 
      });

      test("removes child components by index", () {
        c.addChild(new Component());
        c.addChild(new Component());
        expect(c.children.length, 2); 
        c.removeChild(0);
      });

      test("removes child components by roles", () {
        var c1 = new Component();
        var c2 = new Component();
        c.addChild(c1);
        c.addChild(c2);
        c1.roles.add("button");
        c2.roles.add("link");
        expect(c.children.length, 2); 
        c.removeChild("button", #role);
        expect(c.children.length, 1); 
      });

    });

    group("with events", () {

      test("emits events to its parent", () {
      });

      test("receives events from its children", () {
      });

    });

  });

}
