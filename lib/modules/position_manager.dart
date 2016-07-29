part of nest_ui;

class PositionManager {

  Map getPosition(HtmlElement el) {
    var pos = el.getBoundingClientRect();
    return { 'x': pos.left, 'y': pos.top };
  }

  Map getDimensions(HtmlElement el) {
    var pos = el.getBoundingClientRect();
    return { 'x': pos.width, 'y': pos.height };
  }
  
  placeAt(el,x,y) {
    el.style..top  = (y.toString() + 'px')
            ..left = (x.toString() + 'px');
  }

  placeBy(
    HtmlElement el1,
    HtmlElement el2,
    { double left: 0, double top: 0, double gravity_top: 0, double gravity_left: 0 }
  ) {
    
    var el2_pos = getPosition(el2);
    var el1_dim = getDimensions(el1);
    var el2_dim = getDimensions(el2);

    var pos_offset     = { 'x': el2_dim['x']*left , 'y': el2_dim['y']*top };
    var gravity_offset = { 'x': el1_dim['x']*gravity_left , 'y': el1_dim['y']*gravity_top };
    var new_pos        = { 'x': pos_offset['x']+el2_pos['x']-gravity_offset['x'], 'y': pos_offset['y']+el2_pos['y']-gravity_offset['y'] };

    placeAt(el1, new_pos['x'], new_pos['y']);

  }

  placeByCenter(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, top: 0.5, left: 0.5, gravity_top: 0.5, gravity_left: 0.5);
  }

  placeByTopLeft(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2);
  }

  placeByTopRight(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, left: 1, gravity_left: 1);
  }

  placeByBottomLeft(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, top: 1, gravity_top: 1);
  }

  placeByBottomRight(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, top: 1, left: 1, gravity_left: 1, gravity_top: 1);
  }

  placeAboveTopLeft(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, gravity_top: 1);
  }

  placeBelowBottomLeft(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, top: 1);
  }

  placeAboveTopRight(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, left: 1, gravity_left: 1, gravity_top: 1);
  }

  placeBelowBottomRight(HtmlElement el1, HtmlElement el2) {
    placeBy(el1, el2, top: 1, left: 1, gravity_left: 1);
  }


}
