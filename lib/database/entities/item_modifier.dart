import '../../model/modifier_change_type.dart';

class ItemModifier {
  final String code;
  final String typeCode;
  final ModifierChangeType changeType;
  final bool attributeOnly;
  final String changeRange;
  final int changeRangeModuleNameId;
  final int attributeId;
  final double attributeValue;

  ItemModifier({
    required this.code,
    required this.typeCode,
    required this.changeType,
    required this.attributeOnly,
    required this.changeRange,
    required this.changeRangeModuleNameId,
    required this.attributeId,
    required this.attributeValue,
  });

  factory ItemModifier.fromJson(Map<String, dynamic> json) => ItemModifier(
        code: json['code'],
        typeCode: json['typeCode'],
        changeType: changeTypeValues[json['changeType']]!,
        attributeOnly: json['attributeOnly'],
        changeRange: json['changeRange'],
        changeRangeModuleNameId: json['changeRangeModuleNameId'],
        attributeId: json['attributeId'],
        attributeValue: json['attributeValue'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'typeCode': typeCode,
        'changeType': changeTypeValues.reverse[changeType],
        'attributeOnly': attributeOnly,
        'changeRange': changeRange,
        'changeRangeModuleNameId': changeRangeModuleNameId,
        'attributeId': attributeId,
        'attributeValue': attributeValue,
      };

  ItemModifier copyWith({required double attributeValue}) => ItemModifier(
        code: code,
        typeCode: typeCode,
        changeType: changeType,
        attributeOnly: attributeOnly,
        changeRange: changeRange,
        changeRangeModuleNameId: changeRangeModuleNameId,
        attributeId: attributeId,
        attributeValue: attributeValue,
      );
}
