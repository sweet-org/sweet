import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'group.dart';

part 'category.g.dart';

List<Category> categoriesFromMap(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

@JsonSerializable(includeIfNull: false)
class Category {
  static final int itemToCategoryIdDivisor = 1000000000;
  static final int groupToCategoryIdDivisor = 1000;

  final int id;
  List<Group>? groups;
  final List<int> groupIds;
  final int localisedNameIndex;
  final String sourceName;

  Category(
      {this.id = -1,
      this.groups,
      this.groupIds = const [],
      this.localisedNameIndex = -1,
      this.sourceName = ''});

  factory Category.clone(Category other, List<Group>? groups) => Category(
        id: other.id,
        groups: groups ?? other.groups,
        groupIds: other.groupIds,
        localisedNameIndex: other.localisedNameIndex,
        sourceName: other.sourceName,
      );

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson({bool writeItems = false}) =>
      _$CategoryToJson(this);
}
