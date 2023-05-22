// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      id: json['id'] as String?,
      name: json['name'] as String,
      learntSkills: (json['learntSkills'] as List<dynamic>?)
          ?.map((e) => LearnedSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      csvLink: json['csvLink'] as String?,
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'csvLink': instance.csvLink,
      'learntSkills': instance.learntSkills,
    };
