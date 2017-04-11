part of dartifact;

abstract class AutoShowHide {

  /** Autohides the component (calls hide() on it) after #autohide_delay
    * time passes. Requires the component to have an #autohide_delay and #autohide_future
    * properties.
    */
  autohide() {

    if(this.autohide_delay != null) {
      var f = new Future.delayed(new Duration(seconds: this.autohide_delay));
      this.autohide_future = f;
      f.then((r) {
        if(this.autohide_future == f)
          this.hide();
      });
    }

  }

  /** Autoshows the component (calls show() on it) after #autoshow_delay
    * time passes. Requires the component to have an #autoshow and #autoshow_future
    * properties.
    */
  autoshow() {
    if(this.autoshow_delay != null) {
      var f = new Future.delayed(new Duration(seconds: autoshow_delay));
      this.autoshow_future = f;
      f.then((r) {
        if(this.autoshow_future == f)
          this.show();
      });
    }
  }

}
