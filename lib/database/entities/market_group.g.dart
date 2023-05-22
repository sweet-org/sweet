// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketGroup _$MarketGroupFromJson(Map<String, dynamic> json) => MarketGroup(
      id: json['id'] as int,
      parentId: json['parentId'] as int?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => MarketGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      iconIndex: json['iconIndex'] as int,
      localisationIndex: json['localisationIndex'] as int,
      sourceName: json['sourceName'] as String,
    );

Map<String, dynamic> _$MarketGroupToJson(MarketGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'children': instance.children,
      'items': instance.items,
      'iconIndex': instance.iconIndex,
      'localisationIndex': instance.localisationIndex,
      'sourceName': instance.sourceName,
    };
