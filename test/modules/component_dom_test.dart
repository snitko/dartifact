import '../../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

void main() {

  var c;
  var el;

  setUp(() {
    c  = new Component();
    el = new DivElement();
  });

  group("ComponentDom", () {

    var d1, d2, d3;

    setUp(() {
      d1 = new DivElement();
      d2 = new DivElement();
      d3 = new DivElement();
      d1.attributes["test-attr"] = "test";
      d2.attributes["test-attr"] = "test";
      d3.append(d2);
      el.append(d1);
      el.append(d3);
      c.dom_element = el;
    });

    test("finds all dom descendants with a particular attribute", () {
      expect(c.allDomDescendantsAndSelfWithAttr(el, attr_name: "test-attr", attr_value: "test"), equals([d1,d2]));
    });

    test("finds own dom_element when a particular attribute is present in it", () {
      el.attributes["test-attr"] = "test";
      expect(c.allDomDescendantsAndSelfWithAttr(el, attr_name: "test-attr", attr_value: "test"), equals([el]));
    });

    test("finds first descendant with a particular attribute", () {
      expect(c.firstDomDescendantOrSelfWithAttr(el, attr_name: "test-attr", attr_value: "test"), equals(d1));
    });

    test("read numeric properties and parses them into int or double", () {
      d1.attributes['data-component-attribute-properties'] = "test_attr:test-attr";
      d1.attributes["test-attr"] = "5.312321";
      c.prvt_readPropertyFromNode("test_attr");
      expect(c.attributes["test_attr"], equals(5.312321));
      d1.attributes["test-attr"] = "5";
      c.prvt_readPropertyFromNode("test_attr");
      expect(c.attributes["test_attr"], equals(5));
      d1.attributes["test-attr"] = "5a";
      c.prvt_readPropertyFromNode("test_attr");
      expect(c.attributes["test_attr"], equals("5a"));
    });
    
  });

}
