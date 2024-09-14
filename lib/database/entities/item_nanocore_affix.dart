import 'package:json_annotation/json_annotation.dart';

import 'item.dart';

part 'item_nanocore_affix.g.dart';

@JsonSerializable()
class ItemNanocoreAffix {
  final int attrId;
  final int attrFirstClass;
  final int attrSecondClass;
  final int attrGroup;
  final int attrLevel;
  final int attrCount;
  List<ItemNanocoreAffix>? children;
  Item? item;

  ItemNanocoreAffix({
    required this.attrId,
    required this.attrFirstClass,
    required this.attrSecondClass,
    required this.attrGroup,
    required this.attrLevel,
    required this.attrCount,
    this.children,
    this.item,
  });

  factory ItemNanocoreAffix.fromJson(Map<String, dynamic> json) =>
      _$ItemNanocoreAffixFromJson(json);

  Map<String, dynamic> toJson() => _$ItemNanocoreAffixToJson(this);
}
