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

Object new_instance_of(String class_name, [List args, List<String> libraries]) {

  // Arguments for the class constructor out which
  // the new instance will be obtained.
  if(args is Null)
    args = [];

  var reflectee;
  var cm = class_from_string(class_name, libraries);

  if(cm != null) {
    InstanceMirror im = cm.newInstance(new Symbol(''), args);
    reflectee = im.reflectee;
  }

  return reflectee;

}

ClassMirror class_from_string(String class_name, [List<String> libraries]) {

  if(libraries == null)
    libraries = [""];
  libraries = new Collection(libraries).distinct().toList();

  MirrorSystem mirrors = currentMirrorSystem();
  ClassMirror   cm;
  List          libs = [];
  var           reflectee;

  libraries.forEach((l) {
    if(l == "") {
      mirrors.libraries.values.forEach((l){
        if(l.qualifiedName == new Symbol(''))
          libs.add(l);
      });
    } else {
      libs.add(mirrors.findLibrary(new Symbol(l)));
    }
  });

  libs.forEach((lm) {
    if(cm == null)
      cm = lm.declarations[new Symbol(class_name)];
  });

  return cm;
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

String symbol_to_string(s) {
  return MirrorSystem.getName(s);
}

callMethod(String method_name, Object object, args) {
  if(args == null)
    args = [];
  InstanceMirror im = reflect(object);
  return im.invoke(new Symbol(method_name), args);
}

getTypeName(dynamic obj) {
 return reflect(obj).type.reflectedType.toString();
}
