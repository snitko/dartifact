import '../../lib/dartifact.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

void main() {

  var i18n;

  setUp(() {
    var data_holder = new InputElement();
    data_holder.attributes["data-i18n-json"] = '{ "hello" : "world", "nested" : { "hello" : "world"}}';
    data_holder.attributes["id"] = "i18n_data_holder";
    var data_holder2 = new InputElement();
    data_holder2.attributes["data-i18n-json"] = '{ "hello" : "world2", "hi": "yo"}';
    data_holder2.attributes["id"] = "i18n-2_data_holder";
    document.body.append(data_holder);
    document.body.append(data_holder2);
    i18n = new I18n();
  });

  group("I18n", () {

    test("loads data from an HTML element", () {
      expect(i18n.data, equals({ "hello" : "world", "nested" : { "hello" : "world"}}));
    });

    test("loads data from several HTML elements", () {
      i18n = new I18n(["i18n", "i18n-2"]);
      expect(i18n.data, equals({ "hello" : "world2", "hi" : "yo", "nested" : { "hello" : "world"}}));
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
      expect(i18n.t("hi"), isNull);
      expect(i18n.t("hi.hello.world"), isNull);
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
