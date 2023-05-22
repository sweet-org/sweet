import 'package:expressions/expressions.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../util/localisation_constants.dart';

part 'attribute.g.dart';

@JsonSerializable(includeIfNull: true)
class Attribute {
  static final _evaluator = const ExpressionEvaluator();

  double calculatedValue({required double fromValue}) {
    // Evaluate expression
    var value = _evaluator.eval(
      Expression.parse(attributeFormula),
      {'A': fromValue},
    );

    return value;
  }

  Attribute({
    required this.attributeCategory,
    required this.id,
    required this.attributeName,
    required this.available,
    required this.chargeRechargeTimeId,
    required this.defaultValue,
    required this.highIsGood,
    required this.maxAttributeId,
    required this.attributeOperator,
    required this.stackable,
    required this.toAttrId,
    required this.unitId,
    this.unitLocalisationKey,
    this.attributeSourceUnit,
    this.attributeTip,
    this.attributeSourceName,
    this.nameLocalisationKey,
    this.tipLocalisationKey,
    required this.attributeFormula,
    this.baseValue = 0,
  });

  final int attributeCategory;
  final int id;
  final String attributeName;
  final bool available;
  final int chargeRechargeTimeId;
  final double defaultValue;
  final bool highIsGood;
  final int maxAttributeId;
  final List<int> attributeOperator;
  final bool stackable;
  final List<int> toAttrId;
  final int unitId;

  // cannot be final - for processing reasons
  // for now
  int? unitLocalisationKey;
  String? attributeSourceUnit;
  String? attributeTip;
  String? attributeSourceName;
  int? nameLocalisationKey;
  int? tipLocalisationKey;
  @JsonKey(defaultValue: 'A')
  String attributeFormula;
  @JsonKey(defaultValue: 0)
  final double baseValue;

  factory Attribute.fromJson(Map<String, dynamic> json) =>
      _$AttributeFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeToJson(this);

  @override
  String toString() => toJson().toString();

  static Attribute? fromStaticId({required int id}) {
    switch (id) {
      case -1:
        return Attribute(
          id: id,
          nameLocalisationKey: LocalisationStrings.missileRange,
          attributeFormula:
              'A / 1000000', // Value comes in as milliseconds and meters
          unitLocalisationKey: LocalisationStrings.kmUnit,
          attributeCategory: 0,
          attributeName: '',
          attributeOperator: [],
          available: true,
          defaultValue: 0,
          chargeRechargeTimeId: 0,
          highIsGood: true,
          maxAttributeId: 0,
          stackable: false,
          toAttrId: [],
          unitId: 0,
        );
    }

    return null;
  }

  Attribute copyWith({double? baseValue}) => Attribute(
        attributeCategory: attributeCategory,
        id: id,
        attributeName: attributeName,
        available: available,
        chargeRechargeTimeId: chargeRechargeTimeId,
        baseValue: baseValue ?? this.baseValue,
        defaultValue: defaultValue,
        highIsGood: highIsGood,
        maxAttributeId: maxAttributeId,
        attributeOperator: attributeOperator,
        stackable: stackable,
        toAttrId: toAttrId,
        unitId: unitId,
        attributeFormula: attributeFormula,
      );
}
