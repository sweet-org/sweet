import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'item.dart';

part 'market_group.g.dart';

List<MarketGroup> marketGroupsFromJson(String str) => List<MarketGroup>.from(
    json.decode(str).map((x) => MarketGroup.fromJson(x)));

@JsonSerializable()
class MarketGroup with EquatableMixin {
  final int id;
  final int? parentId;
  final List<MarketGroup> children;
  List<Item>? items;
  final int iconIndex;
  final int localisationIndex;
  final String sourceName;

  static MarketGroup get invalid => MarketGroup(
        id: 0,
        iconIndex: 0,
        localisationIndex: 0,
        sourceName: '',
      );

  MarketGroup({
    required this.id,
    this.parentId,
    List<MarketGroup>? children,
    this.items,
    required this.iconIndex,
    required this.localisationIndex,
    required this.sourceName,
  }) : children = children ?? [];

  bool get isTopLevel => parentId == null;

  factory MarketGroup.clone(
          MarketGroup other, List<MarketGroup>? children, List<Item>? items) =>
      MarketGroup(
          id: other.id,
          children: children ?? other.children,
          items: items ?? other.items,
          parentId: other.parentId,
          localisationIndex: other.localisationIndex,
          sourceName: other.sourceName,
          iconIndex: other.iconIndex);

  factory MarketGroup.fromJson(Map<String, dynamic> json) =>
      _$MarketGroupFromJson(json);
  Map<String, dynamic> toJson() => _$MarketGroupToJson(this);

  @override
  List<Object?> get props => [id];
}
