import 'package:equatable/equatable.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:sweet/model/ship/module_state.dart';


class ImplantFittingSlotModule with EquatableMixin {
  final int moduleId;
  final ImplantSlotType type;
  var state = ModuleState.inactive;

  ImplantFittingSlotModule({
    required this.moduleId,
    required this.type,
    this.state = ModuleState.inactive,
  });

  static ImplantFittingSlotModule get emptyBranch => ImplantFittingSlotModule(
      moduleId: 0, type: ImplantSlotType.branch, state: ModuleState.inactive);
  static ImplantFittingSlotModule get emptyCommon => ImplantFittingSlotModule(
      moduleId: 0, type: ImplantSlotType.common, state: ModuleState.inactive);
  static ImplantFittingSlotModule get emptyUpgrade => ImplantFittingSlotModule(
      moduleId: 0, type: ImplantSlotType.upgrade, state: ModuleState.inactive);
  static ImplantFittingSlotModule get invalid => ImplantFittingSlotModule(
      moduleId: 0, type: ImplantSlotType.disabled, state: ModuleState.inactive);

  static getEmpty(ImplantSlotType type) {
    switch (type) {
      case ImplantSlotType.branch:
        return emptyBranch;
      case ImplantSlotType.common:
        return emptyCommon;
      case ImplantSlotType.upgrade:
        return emptyUpgrade;
      case ImplantSlotType.disabled:
      default:
        return invalid;
    }
  }

  factory ImplantFittingSlotModule.fromJson(Map<String, dynamic> json) =>
      ImplantFittingSlotModule(
        moduleId: json['moduleId'] as int,
        type: ImplantSlotType.values.firstWhere(
                (element) => element.typeId == json['type'] as int),
        state: moduleStateValues[json['state'] as String? ?? ''] ??
            ModuleState.active,
      );

  Map<String, dynamic> toJson() => {
    'moduleId': moduleId,
    'type': type.typeId,
    'state': moduleStateValues.reverse[state],
  };

  ImplantFittingSlotModule copy() => ImplantFittingSlotModule(
    moduleId: moduleId,
    type: type,
    state: state,
  );

  @override
  List<Object?> get props => [
    moduleId,
    type,
    state,
  ];
}
