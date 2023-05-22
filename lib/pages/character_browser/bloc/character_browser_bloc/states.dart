

import 'package:sweet/model/character/character.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class CharacterBrowserState extends Equatable {
  @override
  List<Object> get props => [];
  CharacterBrowserState([List props = const []]) : super();
}

class CharacterBrowserUninitialised extends CharacterBrowserState {}

class CharacterBrowserLoading extends CharacterBrowserState {}

class CharacterBrowserLoaded extends CharacterBrowserState {
  final Iterable<Character> characters;
  final int totalSkillCount;

  CharacterBrowserLoaded(this.characters, this.totalSkillCount);

  @override
  List<Object> get props => [
        characters,
        totalSkillCount,
      ];
}
