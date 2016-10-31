import '../../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

void main() {

  var i18n;

  setUp(() {
    var data_holder = new InputElement();
    data_holder.attributes["data-i18n-json"] = '{ "hello" : "world", "nested" : { "hello" : "world"}}';
    data_holder.attributes["id"] = "i18n_data_holder";
    document.body.append(data_holder);
    i18n = new I18n();
  });

  group("I18n", () {

    test("loads data from an HTML element", () {
      expect(i18n.data, equals({ "hello" : "world", "nested" : { "hello" : "world"}}));
    });

    test("translates a particular key's value", () {
      expect(i18n.t("hello"), equals("world"));
      expect(i18n.t("nested.hello"), equals("world"));
    });

    test("replaces all arguments in a string with a value", () {
      i18n.add("translation.with.args", "hello %w");
      expect(i18n.t("translation.with.args", { "w": "world" }), equals("hello world"));
    });

    test("returns TRANSLATION MISSING if key not found", () {
      expect(i18n.t("hi"), equals("TRANSLATION MISSING for hi"));
      expect(i18n.t("hi.hello.world"), equals("TRANSLATION MISSING for hi.hello.world"));
    });

    test("adds new translations", () {
      i18n.add("translation.with.args", "hello %w");
      expect(i18n.data, equals({ "hello" : "world", "nested" : { "hello" : "world"}, "translation" : { "with": { "args" : "hello %w"}}}));
    });

    test("constructor returns null if HtmlElement data holder isn't found", () {
      expect(new I18n("non-existent-data-holder"), equals(null));
    });

  });

}
