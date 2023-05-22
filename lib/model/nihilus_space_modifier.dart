import 'package:sweet/database/database_exports.dart';

import 'modifier_change_type.dart';

class NihilusSpaceModifier extends ItemModifier {
  final Attribute attribute;

  double get uiValue =>

      /// NetEase updated this to now be A / 1000
      /// which could mean that it's affecting as it should?
      /// The modifier values all appear the same, so I assume it should be OK
      attribute.calculatedValue(
        fromValue: attributeValue - 1, // This is because N-Space is over 100%
      ) *
      100000; // This is to counteract the / 1000 then bump into a percentage

  NihilusSpaceModifier({
    required this.attribute,
    required String code,
    required String typeCode,
    required ModifierChangeType changeType,
    required bool attributeOnly,
    required String changeRange,
    required int changeRangeModuleNameId,
    required int attributeId,
    required double attributeValue,
  }) : super(
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
