part of nest_ui;

class HintComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  HintComponentBehaviors(c) : super(c) {
    this.component = c;
    this.pos.base_offset = { "x": -0.2, "y": 0.2 };
  }

  @override
  show() {

    var has_right_space = _hasSpaceOnTheRight();
    var has_above_space = _hasSpaceAbove();

    this.animator.show(this.dom_element, 1000);

    if(has_right_space && has_above_space) {
      pos.placeAboveTopRightCorner(this.dom_element, this.anchor_el);
      _setPointerArrowClass("arrowBottomLeft");
    }
    else if(has_right_space && !has_above_space) {
      pos.placeBelowBottomRightCorner(this.dom_element, this.anchor_el);
      _setPointerArrowClass("arrowTopLeft");
    }
    else if(!has_right_space && has_above_space) {
      pos.placeAboveTopLeftCorner(this.dom_element, this.anchor_el);
      _setPointerArrowClass("arrowBottomRight");
    }
    else if(!has_right_space && !has_above_space) {
      pos.placeBelowBottomLeftCorner(this.dom_element, this.anchor_el);
      _setPointerArrowClass("arrowTopRight");
    }

  }

  @override
  hide() => this.animator.hide(this.dom_element, 2000);

  bool _hasSpaceOnTheRight() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    return (document.body.clientWidth - (anchor_dimensions.left + anchor_dimensions.width)) > this.dom_element.clientWidth;
  }

  bool _hasSpaceAbove() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    return anchor_dimensions.top > this.dom_element.clientHeight;
  }

  void _setPointerArrowClass(arrow_position_class) {
    this.dom_element.classes.add(arrow_position_class);
  }

  get anchor_el => this.component.anchor_el;


}
