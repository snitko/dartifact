part of nest_ui;

class I18n {

  /** This basically defines dom_element, which is looked up
    * which contains the json for the current I18n instance.
    * The default value here makes sense, since it's sometimes ok
    * to just have on global i18n dom_element as a container for all kinds
    * of values.
    */
  var names;

  /** An Map (with multiple levels) that contains all they key/value pairs
    * with the translations.
    */
  Map data = {};

  /** When translation isn't found, print warning into the console.
    * It sometimes may not be a good idea (for example: Component usually has 2 translators
    * it looks into: its own and RootComponent's), thus this option.
    */
  bool print_console_warning = true;

  factory I18n([names="i18n"]) {
    var i18n_instance = new I18n._internal(names);
    if(i18n_instance.data.isEmpty)
      return null;
    else
      return i18n_instance;
  }

  I18n._internal([n="i18n"]) {
    if(n is String)
      this.names = [n];
    else
      this.names = n;
    loadData();
  }

  /** Takes an HtmlElement defined by id=$name, reads its "data-i18n-json" attribute
    * which, evidently, should contain JSON, decodes it and saves into the #data property.
    * This method is called once while the instance is initialized.
    */
  void loadData() {
    this.names.forEach((n) {
      var data_holder = querySelector("#${n}_data_holder");
      if(data_holder != null)
        this.data = mergeMaps(this.data, JSON.decode(data_holder.attributes["data-i18n-json"]));
    });
  }

  /** The most important method which does the translation.
    *
    * Arguments:
    *
    *   `key`  - a String which represents a key. Could be multilevel,
    *   for example "level1.level2.greeting"
    *
    *   `args` - a Map of arguments and their values to be replaced inside the returned string
    *   (see _subArgs for more information).
    *
    * returns `null` if translation isn't found. Be careful with this: returning null
    * means you don't see any warning message about translation not being found on the
    * screen (only in console). Which means it might be a good idea to not use
    * this class directly and wrap its instances in something else (which is, in fact, the case,
    * because `Component` has its own `#t()` method.
    */
  t(String key, [Map args]) {
    var keys = key.split(".");
    var value = data[keys[0]];
    keys.removeAt(0);

    for(var k in keys) {
      if(value == null) { break; }
      value = value[k];
    }

    if(value == null) {
      if(print_console_warning)
        print("WARNING: translation missing for \"$key\" in \"$names\" translator.");
      return null;
    }

    if(args != null)
      value = _subArgs(args, value);
    return value;
  }

  /** Dynamically adds a new key/value pair into the `data` property. Can be
    * useful when you want to add a translation on the go.
    *
    * Arguments:
    *
    *   `key` - a String which represents a key. Could be multilevel,
    *   for example "level1.level2.greeting"
    *
    *   `value` the actual value that's going to be substituting the key
    *   in the code.
    */
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
