import 'package:json_annotation/json_annotation.dart';

part 'ship_loadout_definition.g.dart';

@JsonSerializable()
class ShipLoadoutDefinition {
  final int numHighSlots;
  final int numMidSlots;
  final int numLowSlots;
  final int numDroneSlots;
  final int numCombatRigSlots;
  final int numEngineeringRigSlots;
  final int numNanocoreSlots;
  final int numLightFrigatesSlots;
  final int numLightDestroyersSlots;
  final int numLightCruisersSlots;
  final int numLightBattlecruisersSlots;
  final int numHangarRigSlots;

  ShipLoadoutDefinition({
    required this.numHighSlots,
    required this.numMidSlots,
    required this.numLowSlots,
    required this.numDroneSlots,
    required this.numCombatRigSlots,
    required this.numEngineeringRigSlots,
    required this.numNanocoreSlots,
    required this.numLightFrigatesSlots,
    required this.numLightDestroyersSlots,
    required this.numLightCruisersSlots,
    required this.numLightBattlecruisersSlots,
    required this.numHangarRigSlots,
  });

  factory ShipLoadoutDefinition.fromJson(Map<String, dynamic> json) =>
      _$ShipLoadoutDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$ShipLoadoutDefinitionToJson(this);
}
