part of nest_ui;

class HintComponentBehaviors extends BaseComponentBehaviors {

  Component component;
  HintComponentBehaviors(c) : super(c) {
    this.component = c;
    this.pos.base_offset = { "x": -0.1, "y": 0.2 };
  }

  @override
  show() {

    // We first need to calculate dimensions and available space on the right and below.
    // Thus, we're using this method.
    displayHidden();

    var has_right_space = _hasSpaceOnTheRight();
    var has_above_space = _hasSpaceAbove();

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

    this.animator.show(this.dom_element, 500);

  }

  @override
  hide() => this.animator.hide(this.dom_element, 500);

  bool _hasSpaceOnTheRight() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    var body_dimensions   = document.body.getBoundingClientRect();
    var hint_dimensions   = this.dom_element.getBoundingClientRect();
    return (body_dimensions.width - (anchor_dimensions.left + anchor_dimensions.width)) > hint_dimensions.width;
  }

  bool _hasSpaceAbove() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    var hint_dimensions   = this.dom_element.getBoundingClientRect();
    return anchor_dimensions.top > hint_dimensions.height;
  }

  void _setPointerArrowClass(arrow_position_class) {
    this.dom_element.classes.removeWhere((c) => c.startsWith("arrow"));
    this.dom_element.classes.add(arrow_position_class);
  }

  get anchor_el => this.component.anchor_el;


}
