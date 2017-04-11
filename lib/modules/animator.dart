part of dartifact;

class Animator {

  Future show(elements, ms, { display_value: "block" }) {
    return _applyToCollection(elements, (el) {
      if((el.offsetHeight > 0 && el.offsetParent == null) || (el.style.opacity == "1" && el.style.display == display_value))
        return;
      el.style.opacity = "0";
      el.style.display = display_value;
      return animate(el, properties: { "opacity": 1 }, duration: ms).onComplete.first;
    });
  }

  Future hide(elements, ms) {
    return _applyToCollection(elements, (el) {
      var animation = animate(el, properties: { "opacity": 0 }, duration: ms).onComplete.first;
      animation.then((i) => el.style.display = "none");
      return animation;
    });
  }

  Future scrollDown(elements, ms, { display_value: "block" }) {
    return _applyToCollection(elements, (el) {
      if(el.offsetHeight > 0 && el.offsetParent == null)
        return;
      el.style.opacity = "0";
      el.style.display = display_value;
      var original_height = el.getBoundingClientRect().height;
      el.style.height = "0px";
      el.style.opacity = "1";
      return animate(el, properties: { "height": "${original_height}px" }, duration: ms).onComplete.first;
    });
  }

  Future scrollUp(elements, ms) {
    return _applyToCollection(elements, (el) {
      var animation = animate(el, properties: { "height": "0px" }, duration: ms).onComplete.first;
      animation.then((i) => el.style.display = "none");
      return animation;
    });
  }

  _applyToCollection(elements, func) {
    if(!(elements is List))
      elements = [elements];

    elements = elements.map((el) {
      if(el is Component)
        return el.dom_element;
      else
        return el;
    });

    var f;
    elements.forEach((el) {
      f = func(el);
    });
    return f;
  }

}
