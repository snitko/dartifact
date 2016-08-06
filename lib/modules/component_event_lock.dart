part of nest_ui;

abstract class ComponentEventLock {

  /** Event locks allow you to prevent similar events being handled twice
    * until the lock is removed. This is useful, for example, to prevent
    * button being clicked twice and, consequently, a form being submitted twice.
    */
  /// Defines which events to use locks for
  List event_lock_for = [];
  /// Stores the locks themselves. If event name is in this List, it's locked.
  List event_locks    = [];

  /** Adds a new event lock. In case the event name is not on the event_lock_for List,
      the lock wouldn't be set. If you want the lock to be set anyway,
      just use the event_locks property directly.
   */
  void addEventLock(event_name, { publisher_roles: null }) {
    var event_names = _prepareFullEventNames(event_name, publisher_roles);
    if(event_locks.toSet().intersection(event_names).isEmpty) {
      if(event_lock_for.contains(event_name))
        event_names.forEach((en) => event_locks.add(en));
    }

  }

  bool hasEventLock(event_name, { publisher_roles: null }) {
    var event_names = _prepareFullEventNames(event_name, publisher_roles);
    if(event_locks.contains(#any) || !(event_locks.toSet().intersection(event_names).isEmpty))
      return true;
    else
      return false;
  }

  Set _prepareFullEventNames(event_name, [publisher_roles=null]) {
    var event_names = new Set();
    publisher_roles.forEach((r) {
      if(r == #self)
        event_names.add(event_name);
      else
        event_names.add("$r.$event_name");
    });
    return event_names;
  }

}
