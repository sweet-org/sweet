import 'package:equatable/equatable.dart';
import 'package:sweet/model/ship/module_state.dart';

class ShipFittingSlotModule with EquatableMixin {
  final int moduleId;
  final Map<String, dynamic> metadata;
  var state = ModuleState.active;

  ShipFittingSlotModule({
    required this.moduleId,
    this.metadata = const {},
    this.state = ModuleState.active,
  });

  static ShipFittingSlotModule get empty => ShipFittingSlotModule(
      moduleId: 0, metadata: {}, state: ModuleState.inactive);

  factory ShipFittingSlotModule.fromJson(Map<String, dynamic> json) =>
      ShipFittingSlotModule(
        moduleId: json['moduleId'] as int,
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
        state: moduleStateValues[json['state'] as String? ?? ''] ??
            ModuleState.active,
      );

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'metadata': metadata,
        'state': moduleStateValues.reverse[state],
      };

  ShipFittingSlotModule copy() => ShipFittingSlotModule(
        moduleId: moduleId,
        metadata: metadata,
        state: state,
      );

  @override
  List<Object?> get props => [
        moduleId,
        metadata,
        state,
      ];
}
