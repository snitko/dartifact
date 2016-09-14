part of nest_ui;

bool isBlank(v) {
  if(v is String)
    return v == null || v.isEmpty;
  else if(v == null)
    return true;
  else
    return false;
}
