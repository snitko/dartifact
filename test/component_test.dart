import '../lib/nest_ui.dart';
import "package:test/test.dart";
import "dart:html";

@TestOn("browser")

class MyComponent extends Component {

  Map event_handlers = {
    'click' : { 'self': (self) => self.events_history.add("self#clicked") }
  };

  List events_history = [];
  List native_events  = ["click", "mouseover"];
  MyComponent(HtmlElement el) : super(el);


}

void main() {

  var c;
  var el;

  setUp(() {
    el = new DivElement();
    c  = new MyComponent(el);
  });

  group("Component", () {
    
    test("streams native browser events and applies component handlers", () {
      el.click();
      expect(c.events_history[0], equals("self#clicked"));
    });

  });

}
