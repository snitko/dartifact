part of nest_ui;

List findSubclasses(name) {

  final ms         = currentMirrorSystem();
  List  subclasses = [];

  ms.libraries.forEach((k,lib) {
    lib.declarations.forEach((k2, c) {
      if(c is ClassMirror && c.superclass != null) {
        final parentClassName = MirrorSystem.getName(c.superclass.simpleName);
        if (parentClassName == name) {
          subclasses.add(c);
        }
      }
    });
  });

  return subclasses;

}

Object new_instance_of(String class_name, [List args, String library='']) {

  // Arguments for the class constructor out which
  // then new instance will be obtained.
  if(args is Null)
    args = [];

  MirrorSystem mirrors = currentMirrorSystem();
  ClassMirror   cm;
  List          libs = [];
  var           reflectee;

  if(library == '') {
    mirrors.libraries.values.forEach((l){
      if(l.qualifiedName == new Symbol('')) {
        libs.add(l);
      }
    });
  }
  else
    libs = [mirrors.findLibrary(new Symbol(library))];

  libs.forEach((lm) {
    cm = lm.declarations[new Symbol(class_name)];

    if(cm != null) {
      InstanceMirror im = cm.newInstance(new Symbol(''), args);
      reflectee = im.reflectee;
      return;
    }
  });

  return reflectee;

}

List<String> methods_of(object) {
  var im = reflect(object);
  List methods = [];
  im.type.instanceMembers.values.forEach((MethodMirror method) {
    methods.add(symbol_to_string(method.simpleName));
  });
  return methods;
}

bool hasMethod(method_name, object) {
  return methods_of(object).contains(method_name);
}

callMethod(String method_name, Object object, args) {
  if(args == null)
    args = [];
  InstanceMirror im = reflect(object);
  return im.invoke(new Symbol(method_name), args);
}

symbol_to_string(s) {
  return MirrorSystem.getName(s);
}
