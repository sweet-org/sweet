import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'group.dart';
import '../../model/items/eve_echoes_categories.dart';

part 'item.g.dart';

List<Item> itemsFromMap(String str) =>
    List<Item>.from(json.decode(str).map((x) => Item.fromJson(x)));

String itemsToMap(List<Item> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable(includeIfNull: true)
class Item {
  static const Item invalid = Item(id: 0, nameKey: 0);

  const Item({
    required this.id,
    // this.basePrice,
    // this.canBeJettisoned,
    // this.capacity,
    // this.factionId,
    // this.iconId,
    // this.isOmega,
    this.mainCalCode,
    this.activeCalCode,
    this.onlineCalCode,
    // this.mass,
    // this.prefabId,
    // this.radius,
    // this.soundId,
    // this.volume,
    this.sourceDesc,
    this.sourceName,
    required this.nameKey,
    this.descKey,
    this.descSpecial,
    this.marketGroupId,
    this.exp,
    this.published,
    this.preSkill,
    this.shipBonusCodeList,
    this.shipBonusSkillList,
    this.product,
    // this.dropRate,
    // this.graphicId,
    // this.raceId,
    // this.sofFactionName,
    // this.lockSkin,
    // this.npcCalCodes,
    // this.lockWreck,
    // this.skinId,
    // this.corporationId,
    // this.portraitPath,
    // this.cloneLv,
    // this.effectGroup,
    // this.initLv,
    // this.techLv,
    // this.corpCamera,
    // this.wreckId,
    // this.museumCredit,
    // this.museumPosition1,
    // this.museumPosition2,
    // this.wikiId,
    // this.bigIconPath,
    // this.boxDropId,
    // this.funParam,
    // this.isObtainable,
    // this.medalSourceText,
    // this.abilityList,
    // this.baseDropRate,
    // this.normalDebris,
    // this.isRookieInsurance,
  });

  final int id;
  // @JsonKey(defaultValue: 0)
  // final int? basePrice;
  // final bool? canBeJettisoned;
  // final int? capacity;
  // final int? factionId;
  // @JsonKey(defaultValue: 0)
  // final int? iconId;
  // @JsonKey(defaultValue: 0)
  // final int? isOmega;
  // @JsonKey(defaultValue: '')
  final String? mainCalCode;
  final String? onlineCalCode;
  final String? activeCalCode;
  // final double? mass;
  // final int? prefabId;
  // @JsonKey(defaultValue: 0)
  // final int? radius;
  // final int? soundId;
  // @JsonKey(defaultValue: 0)
  // final double? volume;
  final String? sourceDesc;
  final String? sourceName;
  final int nameKey;
  final int? descKey;
  final List<int>? descSpecial;
  // @JsonKey(defaultValue: 0)
  // final double? dropRate;
  final int? marketGroupId;
  // final int? graphicId;
  // final int? raceId;
  // final String? sofFactionName;
  // final List<String>? lockSkin;
  // final List<String>? npcCalCodes;
  // final int? lockWreck;
  final int? product;
  // final int? skinId;
  // final int? corporationId;
  // final String? portraitPath;
  // final int? cloneLv;
  // final String? effectGroup;
  // @JsonKey(defaultValue: 0)
  final List<String>? preSkill;
  final double? exp;
  final int? published;
  // final int? initLv;
  // @JsonKey(defaultValue: 0)
  // final int? techLv;
  // final List<double>? corpCamera;
  // final int? wreckId;
  // final int? museumCredit;
  // final int? museumPosition1;
  // final int? museumPosition2;
  // final String? wikiId;
  // final String? bigIconPath;
  // final int? boxDropId;
  // final String? funParam;
  // @JsonKey(defaultValue: 0)
  // final int? isObtainable;
  // final int? medalSourceText;
  // final List<int>? abilityList;
  // @JsonKey(defaultValue: 0)
  // final double? baseDropRate;
  // final List<int>? normalDebris;
  final List<String>? shipBonusCodeList;
  final List<int>? shipBonusSkillList;
  // @JsonKey(defaultValue: 0)
  // final double? isRookieInsurance;

  int get categoryId => id ~/ Category.itemToCategoryIdDivisor;
  int get groupId => id ~/ Group.itemToGroupIdDivisor;
  int get parentMarketGroupId => (marketGroupId ?? 0) ~/ 100000;

  bool get excludeInCapacitorSimulation {
    return categoryId == EveEchoesCategory.drones.categoryId;
  }

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
