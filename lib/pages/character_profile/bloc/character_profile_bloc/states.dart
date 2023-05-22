import 'package:sweet/model/character/character.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:sweet/database/entities/group.dart';

@immutable
abstract class CharacterProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class CharacterProfileUninitialised extends CharacterProfileState {}

abstract class CharacterProfileUpdate extends CharacterProfileState {
  final Character character;
  final List<Group> skillGroups;
  final bool showSpinner;

  CharacterProfileUpdate({
    required this.character,
    required this.skillGroups,
    this.showSpinner = false,
  }) : super();
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class CharacterProfileUpdating extends CharacterProfileUpdate {
  CharacterProfileUpdating({
    required Character character,
    required List<Group> skillGroups,
    required bool showSpinner,
  }) : super(
          character: character,
          skillGroups: skillGroups,
          showSpinner: showSpinner,
        );
}

class CharacterProfileUpdated extends CharacterProfileUpdate {
  CharacterProfileUpdated({
    required Character character,
    required List<Group> skillGroups,
  }) : super(
          character: character,
          skillGroups: skillGroups,
          showSpinner: false,
        );
}

class ShowStatusUpdate extends CharacterProfileState {
  final String message;

  ShowStatusUpdate(this.message);
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}
