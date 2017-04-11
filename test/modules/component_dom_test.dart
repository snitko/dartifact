import '../../lib/dartifact.dart';
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

    var d1, d2, d3, part1, part2;

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

    test("finds component parts with a particular name", () {
      part1 = new DivElement();
      part2 = new DivElement();
      part1.attributes["data-component-part"] = "some_part";
      part2.attributes["data-component-part"] = "some_part";
      el.append(part1);
      el.append(part2);
      expect(c.findAllParts("some_part"), equals([part1, part2]));
      expect(c.findPart("some_part"), equals(part1));
      expect(c.findAllParts("some_other_part"), isEmpty);
      expect(c.findPart("some_other_part"), equals(null));
    });
    
    
  });

}
