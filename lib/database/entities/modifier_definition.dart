import '../../model/modifier_change_type.dart';

class ModifierDefinition {
  ModifierDefinition({
    required this.code,
    required this.changeTypes,
    required this.attributeOnly,
    required this.changeRanges,
    required this.changeRangeModuleNames,
    required this.attributeIds,
  });

  final String code;
  final List<ModifierChangeType> changeTypes;
  final bool attributeOnly;
  final List<String> changeRanges;
  final List<int> changeRangeModuleNames;
  final List<int> attributeIds;

  factory ModifierDefinition.fromJson(Map<String, dynamic> json) =>
      ModifierDefinition(
        code: json['code'],
        changeTypes: List<ModifierChangeType>.from(
            json['changeTypes'].map((x) => changeTypeValues[x])),
        attributeOnly: json['attributeOnly'],
        changeRanges: List<String>.from(json['changeRanges'].map((x) => x)),
        changeRangeModuleNames:
            List<int>.from(json['changeRangeModuleNames'].map((x) => x)),
        attributeIds: List<int>.from(json['attributeIds'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'changeTypes': List<String>.from(
            changeTypes.map((x) => changeTypeValues.reverse[x])),
        'attributeOnly': attributeOnly,
        'changeRanges': List<String>.from(changeRanges.map((x) => x)),
        'changeRangeModuleNames':
            List<int>.from(changeRangeModuleNames.map((x) => x)),
        'attributeIds': List<int>.from(attributeIds.map((x) => x)),
      };
}
