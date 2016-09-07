part of nest_ui;

class EditableSelectComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  EditableSelectComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  showAjaxIndicator() {
    var i = ajaxIndicator;
    if(i != null)
      i.style.display = "inline";
  }

  hideAjaxIndicator() {
    var i = ajaxIndicator;
    if(i != null)
      i.style.display = "none";
  }

  showNoOptionsFound() {
    var el = this.dom_element.querySelector(".noOptionsFoundMessage");
    if(el != null)
      el.style.display = "block";
  }

  hideNoOptionsFound() {
    var el = this.dom_element.querySelector(".noOptionsFoundMessage");
    if(el != null)
      el.style.display = "none";
  }

  disable() {
    var input = this.dom_element.querySelector("[data-component-part=\"input\"]");
    input.attributes["disabled"]    = "disabled";
    input.attributes["data-placeholder"] = input.attributes["placeholder"];
    input.attributes["placeholder"] = "";
  }

  enable() {
    var input = this.dom_element.querySelector("[data-component-part=\"input\"]");
    this.dom_element.querySelector("[data-component-part=\"input\"]").attributes.remove("disabled");
    input.attributes["placeholder"] = input.attributes["data-placeholder"];
  }

  HtmlElement get ajaxIndicator {
    return this.dom_element.querySelector(".ajaxIndicator");
  }


}
