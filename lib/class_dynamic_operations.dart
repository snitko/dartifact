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

Object new_instance_of(String class_name, [String library='']) {

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
      InstanceMirror im = cm.newInstance(new Symbol(''), []);
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

symbol_to_string(s) {
  return MirrorSystem.getName(s);
}
