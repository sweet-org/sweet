

import 'package:json_annotation/json_annotation.dart';

part 'item_effect.g.dart';

@JsonSerializable()
class ItemEffect {
  final int itemId;
  final int effectId;
  final bool isDefault;

  factory ItemEffect.fromJson(Map<String, dynamic> json) =>
      _$ItemEffectFromJson(json);

  Map<String, dynamic> toJson() => _$ItemEffectToJson(this);

  ItemEffect(this.effectId, this.isDefault, this.itemId);
}
