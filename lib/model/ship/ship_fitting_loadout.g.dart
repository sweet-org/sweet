// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_fitting_loadout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipFittingLoadout _$ShipFittingLoadoutFromJson(Map<String, dynamic> json) =>
    ShipFittingLoadout(
      id: json['id'] as String?,
      name: json['name'] as String,
      shipItemId: (json['shipItemId'] as num).toInt(),
      highSlots:
          ShipFittingSlot.fromJson(json['highSlots'] as Map<String, dynamic>),
      midSlots:
          ShipFittingSlot.fromJson(json['midSlots'] as Map<String, dynamic>),
      lowSlots:
          ShipFittingSlot.fromJson(json['lowSlots'] as Map<String, dynamic>),
      combatRigSlots: ShipFittingSlot.fromJson(
          json['combatRigSlots'] as Map<String, dynamic>),
      engineeringRigSlots: ShipFittingSlot.fromJson(
          json['engineeringRigSlots'] as Map<String, dynamic>),
      droneBay:
          ShipFittingSlot.fromJson(json['droneBay'] as Map<String, dynamic>),
      nanocoreSlots: ShipFittingSlot.fromJson(
          json['nanocoreSlots'] as Map<String, dynamic>),
      lightFrigatesSlots: ShipFittingSlot.fromJson(
          json['lightFrigatesSlots'] as Map<String, dynamic>),
      lightDestroyersSlots: ShipFittingSlot.fromJson(
          json['lightDestroyersSlots'] as Map<String, dynamic>),
      lightCruisersSlots: ShipFittingSlot.fromJson(
          json['lightCruisersSlots'] as Map<String, dynamic>),
      lightBattlecruisersSlots: ShipFittingSlot.fromJson(
          json['lightBattlecruisersSlots'] as Map<String, dynamic>),
      hangarRigSlots: ShipFittingSlot.fromJson(
          json['hangarRigSlots'] as Map<String, dynamic>),
      implantIds: (json['implantIds'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
    );

Map<String, dynamic> _$ShipFittingLoadoutToJson(ShipFittingLoadout instance) =>
    <String, dynamic>{
      'type': instance._type,
      'id': instance.id,
      'shipItemId': instance.shipItemId,
      'name': instance.name,
      'implantIds': instance.implantIds,
      'highSlots': instance.highSlots,
      'midSlots': instance.midSlots,
      'lowSlots': instance.lowSlots,
      'combatRigSlots': instance.combatRigSlots,
      'engineeringRigSlots': instance.engineeringRigSlots,
      'droneBay': instance.droneBay,
      'nanocoreSlots': instance.nanocoreSlots,
      'lightFrigatesSlots': instance.lightFrigatesSlots,
      'lightDestroyersSlots': instance.lightDestroyersSlots,
      'lightCruisersSlots': instance.lightCruisersSlots,
      'lightBattlecruisersSlots': instance.lightBattlecruisersSlots,
      'hangarRigSlots': instance.hangarRigSlots,
    };
