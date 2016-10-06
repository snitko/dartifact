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

    this.dom_element.style.display = "block";

    if(has_right_space && has_above_space)
      pos.placeAboveTopRightCorner(this.dom_element, this.anchor_el);
    else if(has_right_space && !has_above_space)
      pos.placeBelowBottomRightCorner(this.dom_element, this.anchor_el);
    else if(!has_right_space && has_above_space)
      pos.placeAboveTopLeftCorner(this.dom_element, this.anchor_el);
    else if(!has_right_space && !has_above_space)
      pos.placeBelowBottomLeftCorner(this.dom_element, this.anchor_el);

  }

  bool _hasSpaceOnTheRight() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    return (document.body.clientWidth - (anchor_dimensions.left + anchor_dimensions.width)) > this.dom_element.clientWidth;
  }

  bool _hasSpaceAbove() {
    var anchor_dimensions = this.anchor_el.getBoundingClientRect();
    return anchor_dimensions.top > this.dom_element.clientHeight;
  }

  get anchor_el => this.component.anchor_el;


}
