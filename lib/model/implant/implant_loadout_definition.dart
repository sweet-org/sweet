import 'package:json_annotation/json_annotation.dart';
import 'package:sweet/model/implant/slot_type.dart';

part 'implant_loadout_definition.g.dart';

@JsonSerializable()
class ImplantLoadoutDefinition {
  final Map<int, ImplantSlotType> slots;
  final Map<int, List<int>> restrictions;

  ImplantLoadoutDefinition({
    required this.slots,
    required this.restrictions
  });

  factory ImplantLoadoutDefinition.fromJson(Map<String, dynamic> json) =>
      _$ImplantLoadoutDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$ImplantLoadoutDefinitionToJson(this);
}
