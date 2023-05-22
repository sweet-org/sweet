import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/character/character.dart';
import '../model/character/learned_skill.dart';
import '../model/fitting/fitting_skill.dart';

class CharacterRepository {
  static final noSkillCharacterId = 'no-skills';
  static final maxSkillCharacterId = 'all-skills';

  static final String prefsKey = 'charactersJson';
  static final String defaultPilotPrefsKey = 'defaultPilot';

  List<Character> _characters = [];
  String? _defaultPilotId;
  Iterable<Character> get characters => _characters;

  Character get lv5Character => _lv5Character;
  late Character _lv5Character;

  Future<bool> loadCharacters(
      {List<Character>? data, String? defaultPilot}) async {
    if (data != null) {
      _characters = data;
      _defaultPilotId = defaultPilot;
    } else {
      var prefs = await SharedPreferences.getInstance();
      var json = prefs.getString(prefsKey);
      if (json != null && json.isNotEmpty) {
        _characters = charactersFromJson(json);
      }

      _defaultPilotId = prefs.getString(defaultPilotPrefsKey);
    }
    return true;
  }

  Character get defaultPilot {
    final pilot = getCharacter(_defaultPilotId);

    if (pilot != null) return pilot;

    return _defaultPilotId == CharacterRepository.maxSkillCharacterId
        ? lv5Character
        : Character.empty;
  }

  Future<bool> setDefaultPilot({required Character pilot}) async {
    var prefs = await SharedPreferences.getInstance();
    _defaultPilotId = pilot.id;
    return prefs.setString(defaultPilotPrefsKey, _defaultPilotId!);
  }

  Character? getCharacter(String? id) =>
      _characters.firstWhereOrNull((c) => c.id == id);

  Future<bool> saveCharacters() async {
    var json = jsonEncode(_characters);
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString(prefsKey, json);
  }

  Future<bool> addCharacter(Character character) async {
    _characters.removeWhere((c) => c.id == character.id);
    _characters.add(character);
    return saveCharacters();
  }

  Future<bool> deleteCharacter({required String characterId}) async {
    _characters.removeWhere((character) => character.id == characterId);
    return saveCharacters();
  }

  void createMaxSkillCharacter({required Iterable<FittingSkill> skills}) {
    _lv5Character = Character(
      id: CharacterRepository.maxSkillCharacterId,
      name: 'Max Skills',
      learntSkills: skills
          .map(
            (s) => LearnedSkill(skillId: s.itemId, skillLevel: 5),
          )
          .toList(),
    );
  }

  Future<bool> moveCharacter(
      {required Character character, required int newIndex}) async {
    var index = _characters.indexWhere((e) => e.id == character.id);

    if (index >= 0) {
      print('Moving ${character.name} to $newIndex');

      _characters.removeAt(index);
      _characters.insert(newIndex, character);

      return saveCharacters();
    }

    return false;
  }
}
