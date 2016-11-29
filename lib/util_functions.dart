part of nest_ui;

bool isBlank(v) {
  if(v is String)
    return v == null || v.isEmpty;
  else if(v == null)
    return true;
  else
    return false;
}

Map mergeMaps(map1, map2, { deep: false }) {
  map2.forEach((k,v) {
    if(deep && map1[k] is Map && v is Map)
      map1[k] = mergeMaps(map1[k], v);
    else
      map1[k] = v;
  });
  return map1;
}

String symToString(sym) {
  return MirrorSystem.getName(sym);
}
