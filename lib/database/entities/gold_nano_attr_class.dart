import 'package:json_annotation/json_annotation.dart';

import 'item_nanocore_affix.dart';

part 'gold_nano_attr_class.g.dart';

@JsonSerializable()
class GoldNanoAttrClass {
  final int classId;
  final int classLevel;
  final int parentClassId;
  final String sourceName;
  final int nameKey;
  List<GoldNanoAttrClass> children;
  List<ItemNanocoreAffix>? items;

  GoldNanoAttrClass({
    required this.classId,
    required this.classLevel,
    required this.parentClassId,
    required this.sourceName,
    required this.nameKey,
    List<GoldNanoAttrClass>? children,
    this.items,
  }) : children = children ?? [];

  factory GoldNanoAttrClass.fromJson(Map<String, dynamic> json) =>
      _$GoldNanoAttrClassFromJson(json);

  Map<String, dynamic> toJson() => _$GoldNanoAttrClassToJson(this);
}
