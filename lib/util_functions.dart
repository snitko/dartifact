part of nest_ui;

bool isBlank(v) {
  if(v is int)
    return v == null;
  else if(v is String)
    return v == null || v.isEmpty;
}
