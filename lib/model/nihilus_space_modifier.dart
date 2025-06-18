import 'package:sweet/database/database_exports.dart';


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
    required super.code,
    required super.typeCode,
    required super.changeType,
    required super.attributeOnly,
    required super.changeRange,
    required super.changeRangeModuleNameId,
    required super.attributeId,
    required super.attributeValue,
  });
}
