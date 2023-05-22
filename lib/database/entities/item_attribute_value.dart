

import 'package:json_annotation/json_annotation.dart';

part 'item_attribute_value.g.dart';

@JsonSerializable()
class ItemAttributeValue {
  final int itemId;
  final int attributeId;
  final double value;

  factory ItemAttributeValue.fromJson(Map<String, dynamic> json) =>
      _$ItemAttributeValueFromJson(json);

  Map<String, dynamic> toJson() => _$ItemAttributeValueToJson(this);

  ItemAttributeValue(this.attributeId, this.value, this.itemId);
}
