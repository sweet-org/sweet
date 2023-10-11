

import 'package:sweet/model/character/character.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class CharacterBrowserEvent extends Equatable {
  @override
  List<Object> get props => [];
  CharacterBrowserEvent([List props = const []]) : super();
}

class LoadCharacters extends CharacterBrowserEvent {}

class AddNewCharacter extends CharacterBrowserEvent {
  final String characterName;
  final int baseLvl;
  final int advLvl;
  final int expLvl;

  AddNewCharacter({
    required this.characterName,
    required this.baseLvl,
    required this.advLvl,
    required this.expLvl
  });

  @override
  List<Object> get props => [characterName, baseLvl, advLvl, expLvl];
}

class CloneCharacter extends CharacterBrowserEvent {
  final Character character;
  final String characterName;

  CloneCharacter({required this.character, required this.characterName});

  @override
  List<Object> get props => [
        character,
        characterName,
      ];
}

class ImportCharacter extends CharacterBrowserEvent {
  final Character character;

  ImportCharacter({required this.character});

  @override
  List<Object> get props => [character];
}

class DeleteCharacter extends CharacterBrowserEvent {
  final String characterId;

  DeleteCharacter({required this.characterId});

  @override
  List<Object> get props => [characterId];
}

class ReorderCharacter extends CharacterBrowserEvent {
  final Character character;
  final int newIndex;

  ReorderCharacter({
    required this.character,
    required this.newIndex,
  });

  @override
  List<Object> get props => [
        character,
        newIndex,
      ];
}
