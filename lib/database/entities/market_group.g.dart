// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketGroup _$MarketGroupFromJson(Map<String, dynamic> json) => MarketGroup(
      id: (json['id'] as num).toInt(),
      parentId: (json['parentId'] as num?)?.toInt(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => MarketGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      iconIndex: (json['iconIndex'] as num).toInt(),
      localisationIndex: (json['localisationIndex'] as num).toInt(),
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
