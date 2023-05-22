import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'item.dart';

part 'group.g.dart';

List<Group> groupsFromMap(String str) =>
    List<Group>.from(json.decode(str).map((x) => Group.fromJson(x)));

@JsonSerializable(includeIfNull: false)
class Group {
  static final int itemToGroupIdDivisor = 1000000;

  final int id;
  // final bool anchorable;
  // final bool anchored;
  // final bool fittableNonSingleton;
  // final String iconPath;
  // final bool useBasePrice;
  final int localisedNameIndex;
  final String sourceName;
  final List<int>? itemIds;
  List<Item>? items;

  int get categoryId => id ~/ 1000;

  Group({
    required this.id,
    // required this.anchorable,
    // required this.anchored,
    // required this.fittableNonSingleton,
    // required this.iconPath,
    // required this.useBasePrice,
    required this.localisedNameIndex,
    required this.sourceName,
    this.itemIds,
    this.items,
  });

  factory Group.clone(Group other, List<Item>? items) => Group(
        id: other.id,
        items: items ?? other.items,
        // anchorable: other.anchorable,
        // anchored: other.anchored,
        // fittableNonSingleton: other.fittableNonSingleton,
        // iconPath: other.iconPath,
        // useBasePrice: other.useBasePrice,
        localisedNameIndex: other.localisedNameIndex,
        sourceName: other.sourceName,
      );

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson({bool writeItems = false}) => _$GroupToJson(this);
}
