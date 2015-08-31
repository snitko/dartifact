import '../lib/very_ui.dart';
import "package:test/test.dart";

@TestOn("browser")

void main() {

  group("Component", () {

    test("dummy test", () {
      new Component();
      expect(1, equals(1));
    });

  });

}
