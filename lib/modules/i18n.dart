part of nest_ui;

class I18n {

  /** This basically defines dom_element, which is looked up
    * which contains the json for the current I18n instance.
    * The default value here makes sense, since it's sometimes ok
    * to just have on global i18n dom_element as a container for all kinds
    * of values.
    */
  String name;

  /** An Map (with multiple levels) that contains all they key/value pairs
    * with the translations.
    */
  Map data;

  I18n([this.name="i18n"]) {
    loadData();
  }

  void loadData() {
    var data_holder = querySelector("#${name}_data_holder");
    data = JSON.decode(data_holder.attributes["data-i18n-json"]);
  }

  String t(String key, [Map args]) {
    var keys = key.split(".");
    var value = data[keys[0]];
    keys.removeAt(0);

    for(var k in keys) {
      if(value == null) { break; }
      value = value[k];
    }

    if(value == null)
      return "TRANSLATION MISSING for $key";

    if(args != null)
      value = _subArgs(args, value);
    return value;
  }

  void add(String key, String value) {
    var keys = key.split(".");
    var keys_map = value;

    keys.reversed.forEach((k) {
      keys_map = { k: keys_map };
    });

    mergeMaps(data, keys_map, deep: true);
  }

  /** Substitues argument placeholders in a String for their values.
    * For example:
    *
    *   _subArgs("Hello %w", { "w" : "World" })
    *
    * would return "Hello World";
    */
  String _subArgs(Map args, String string) {
    args.forEach((k,v) => string = string.replaceAll(new RegExp("%$k"), v));
    return string;
  }

}
