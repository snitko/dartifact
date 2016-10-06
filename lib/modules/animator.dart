part of nest_ui;

class Animator {

  Future show(el, ms) {
    el.style.opacity = "0";
    el.style.display = "block";
    var f = animate(el, properties: { "opacity": 1 }, duration: ms).onComplete.first;
    return f;
  }

  Future hide(el, ms) {
    var f = animate(el, properties: { "opacity": 0 }, duration: ms).onComplete.first;
    f.then((i) => el.style.display = "none");
    return f;
  }

  Future scrollDown(el, ms) {
    el.style.opacity = "0";
    el.style.display = "block";
    var original_height = el.getBoundingClientRect().height;
    el.style.height = "0px";
    el.style.opacity = "1";
    var f = animate(el, properties: { "height": "${original_height}px" }, duration: ms).onComplete.first;
    return f;
  }

  Future scrollUp(el, ms) {
    var f = animate(el, properties: { "height": "0px" }, duration: ms).onComplete.first;
    f.then((i) => el.style.display = "none");
    return f;
  }

}
