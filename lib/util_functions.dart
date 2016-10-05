part of nest_ui;

bool isBlank(v) {
  if(v is String)
    return v == null || v.isEmpty;
  else if(v == null)
    return true;
  else
    return false;
}

Map mergeMaps(map1, map2) {
  map2.forEach((k,v) {
    map1[k] = v;
  });
  return map1;
}
