import 'package:sweet/util/enum_values.dart';

enum ModuleState {
  inactive,
  active,
  overload,
}

final moduleStateValues = EnumValues({
  'inactive': ModuleState.inactive,
  'active': ModuleState.active,
  'overload': ModuleState.overload,
});
