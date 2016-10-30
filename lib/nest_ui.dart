library nest_ui;

// vendor libs
import 'dart:html'   ;
import 'dart:convert';
import 'dart:mirrors';

// Collection is used by SelectComponent, which is not necessarily loaded
// (use decides wether to load it or not). Exporting us required in such cases.
import 'dart:collection';
export 'dart:collection';
import 'dart:async';
export 'dart:async';
export 'dart:convert';

// vendor libs from pub packages
import 'package:queries/collections.dart';
import 'package:cookie/cookie.dart' as cookie;
import 'package:animation/animation.dart';

// nest_ui satellite libs
import 'package:observable_roles/observable_roles.dart' as observable;
import 'package:heritage_tree/heritage_tree.dart';
import 'package:attributable/attributable.dart';
import 'package:validatable/validatable.dart';
export 'package:logmaster/logmaster.dart';

// parts of the current lib
part 'class_dynamic_operations.dart';
part 'util_functions.dart';
part 'modules/component_dom.dart';
part 'modules/component_heritage.dart';
part 'modules/component_validation.dart';
part 'modules/component_event_lock.dart';
part 'modules/position_manager.dart';
part 'modules/animator.dart';
part 'modules/auto_show_hide.dart';

part 'component.dart';
part 'native_events_list.dart';
part 'behaviors/base_component_behaviors.dart';
part 'behaviors/form_field_component_behaviors.dart';
part 'components/form_field_component.dart';
part 'components/numeric_form_field_component.dart';
part 'components/radio_button_component.dart';
part 'components/root_component.dart';

/* These ones are not included by default. Placed here to
 * explicitly explain that and also so that when documentation is generated,
 * we can uncomment it and include it into the documentation.
 */
/*********************************************************************/
//part 'behaviors/select_component_behaviors.dart';
//part 'components/select_component.dart';
//part 'behaviors/editable_select_component_behaviors.dart';
//part 'components/editable_select_component.dart';
//part 'behaviors/hint_component_behaviors.dart';
//part 'components/hint_component.dart';
//part 'behaviors/simple_notification_component_behaviors.dart';
//part 'components/simple_notification_component.dart';

//part 'test_helpers/component_test_helpers.dart';
//part 'test_helpers/form_field_component_test_helpers.dart';
//part 'test_helpers/hint_component_test_helpers.dart';
//part 'test_helpers/radio_button_component_test_helpers.dart';
//part 'test_helpers/select_component_test_helpers.dart';
//part 'test_helpers/simple_notification_component_test_helpers.dart';
/*********************************************************************/

part 'nest_ui_app.dart';
