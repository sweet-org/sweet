import 'package:json_annotation/json_annotation.dart';

part 'item_nanocore.g.dart';

@JsonSerializable()
class ItemNanocore {
  final int itemId;
  final String filmGroup;
  final int filmQuality;
  final List<int> availableShips;
  final List<int> selectableModifierItems;
  final List<List<int>> trainableModifierItems;

  ItemNanocore({
    required this.itemId,
    required this.filmGroup,
    required this.filmQuality,
    required this.availableShips,
    required this.selectableModifierItems,
    required this.trainableModifierItems,
  });

  factory ItemNanocore.fromJson(Map<String, dynamic> json) =>
      _$ItemNanocoreFromJson(json);

  Map<String, dynamic> toJson() => _$ItemNanocoreToJson(this);
}
