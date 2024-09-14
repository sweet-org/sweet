import 'package:json_annotation/json_annotation.dart';

part 'level_attribute.g.dart';

@JsonSerializable(includeIfNull: true)
class LevelAttribute {
  LevelAttribute({
    required this.attrId,
    required this.formula,
  });

  final int attrId;
  final String formula;

  factory LevelAttribute.fromJson(Map<String, dynamic> json) =>
      _$LevelAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$LevelAttributeToJson(this);
}
