import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class CharacterProfileEvent extends Equatable {}

class LoadCharacter extends CharacterProfileEvent {
  @override
  List<Object> get props => [];
}

class UpdateCharacterDetails extends CharacterProfileEvent {
  final String characterName;
  final String characterId;

  UpdateCharacterDetails(this.characterName, this.characterId);

  @override
  List<Object> get props => [characterName, characterId];
}

class UpdateCharacterSkill extends CharacterProfileEvent {
  final int level;
  final int skillId;

  UpdateCharacterSkill(this.level, this.skillId);

  @override
  List<Object> get props => [skillId, level];
}

class UpdateCharacterFromPastebin extends CharacterProfileEvent {
  final String url;

  UpdateCharacterFromPastebin(this.url);

  @override
  List<Object> get props => [url];
}

class ExportCharacterSkills extends CharacterProfileEvent {
  final String filePath;

  ExportCharacterSkills({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class ImportCharacterSkills extends CharacterProfileEvent {
  final String filePath;

  ImportCharacterSkills({required this.filePath});

  @override
  List<Object> get props => [filePath];
}
