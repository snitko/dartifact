part of dartifact;

class EditableSelectComponentBehaviors extends BaseComponentBehaviors {

  Component component;

  EditableSelectComponentBehaviors(Component c) : super(c) {
    this.component = c;
  }

  disable() {
    this.dom_element.attributes["disabled"] = "disabled";
    this.input.attributes["disabled"] = "disabled";
    if(!isBlank(this.input.attributes["placeholder"])) {
      this.input.attributes["data-placeholder"] = input.attributes["placeholder"];
      this.input.attributes["placeholder"] = "";
    }
  }

  enable() {
    this.dom_element.attributes.remove("disabled");
    this.input.attributes.remove("disabled");
    if(input.attributes["data-placeholder"] != null)
      this.input.attributes["placeholder"] = input.attributes["data-placeholder"];
  }

  HtmlElement get input => this.component.findPart("display_input");

}
