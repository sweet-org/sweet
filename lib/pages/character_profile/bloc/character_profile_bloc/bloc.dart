import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'package:sweet/database/entities/group.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/items/skills.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/events.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/states.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';

class CharacterProfileBloc
    extends Bloc<CharacterProfileEvent, CharacterProfileState> {
  final String characterId;
  final CharacterRepository characterRepository;
  final ItemRepository itemRepository;
  final LocalisationRepository localisationRepository;

  late Iterable<Group> skillGroups;
  late Iterable<Item> skills;
  late Iterable<Item> skillsWithPrerequisites;

  CharacterProfileBloc({
    required this.characterId,
    required this.characterRepository,
    required this.itemRepository,
    required this.localisationRepository,
  }) : super(CharacterProfileUninitialised()) {
    _loadSkills().then((_) => add(LoadCharacter()));
    on<CharacterProfileEvent>((event, emit) => mapEventToState(event, emit));
  }

  Future<void> _loadSkills() async {
    skillGroups = await itemRepository.skillGroups(includeItems: true);
    skills = await itemRepository.skillItems.then(
      (s) => s.where((e) => e.published == 1),
    );
    skillsWithPrerequisites = skills.where((e) => e.requiredSkill != null);
  }

  void updateCharacterSkill({
    required Character character,
    required int skillId,
    required int level,
  }) {
    // Check for other skills, and clear if required?
    final reliantSkills = skillsWithPrerequisites.where(
      (e) =>
          e.requiredSkill!.skillId == skillId &&
          e.requiredSkill!.skillLevel > level,
    );
    if (reliantSkills.isNotEmpty) {
      // Clear the reliant skills if we don't have it anymore
      for (var reliantSkill in reliantSkills) {
        updateCharacterSkill(
          character: character,
          skillId: reliantSkill.id,
          level: 0,
        );
      }
    }

    final skill = skills.firstWhereOrNull((e) => e.id == skillId)!;
    if (skill.canBeTrained(knownSkills: character.learntSkills)) {
      character.updateSkill(id: skillId, level: level);
    }
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    CharacterProfileEvent event,
    Emitter<CharacterProfileState> emit,
  ) async {
    if (event is LoadCharacter) {
      var character = characterRepository.getCharacter(characterId)!;

      await characterRepository.saveCharacters();
      emit(CharacterProfileUpdated(
        character: character,
        skillGroups: skillGroups as List<Group>,
      ));
    }

    if (event is UpdateCharacterDetails) {
      var character = characterRepository.getCharacter(characterId)!;
      character.setName(event.characterName, notify: false);
      character.setTotalImplantLevels(event.totalImplantLevels);

      await characterRepository.saveCharacters();
      emit(CharacterProfileUpdated(
        character: character,
        skillGroups: skillGroups as List<Group>,
      ));
    }

    if (event is UpdateCharacterSkill) {
      var character = characterRepository.getCharacter(characterId)!;
      emit(CharacterProfileUpdating(
        character: character,
        skillGroups: skillGroups as List<Group>,
        showSpinner: false,
      ));

      updateCharacterSkill(
        character: character,
        skillId: event.skillId,
        level: event.level,
      );

      await characterRepository.saveCharacters();
      emit(CharacterProfileUpdated(
        character: character,
        skillGroups: skillGroups as List<Group>,
      ));
    }

    if (event is ExportCharacterSkills) {
      exportSkillsToFile(event.filePath, emit);
    }

    if (event is ImportCharacterSkills) {
      importSkillsFromFile(event.filePath, emit);
    }

    if (event is UpdateCharacterFromPastebin) {
      var character = characterRepository.getCharacter(characterId)!;
      emit(CharacterProfileUpdating(
        character: character,
        skillGroups: skillGroups as List<Group>,
        showSpinner: true,
      ));

      final url = Uri.parse(event.url);
      final code = url.pathSegments.last;
      final pasteUrl = Uri.parse('https://pastebin.com/raw/$code');

      print('Downloading from $pasteUrl');
      final response = await http.get(pasteUrl);
      final data = utf8.decode(response.bodyBytes);
      loadCharacterFromCsv(data: data, character: character);

      character.csvLink = event.url;

      await characterRepository.saveCharacters();
      emit(CharacterProfileUpdated(
        character: character,
        skillGroups: skillGroups as List<Group>,
      ));
    }
  }

  void loadCharacterFromCsv({
    required String data,
    required Character character,
  }) {
    final d = const FirstOccurrenceSettingsDetector(
        eols: ['\r\n', '\n'], textDelimiters: ['"', "'"]);
    final lines =
        const CsvToListConverter().convert(data, csvSettingsDetector: d);
    final entries = lines.map((line) {
      if (line.length < 3 || line[0] is String) {
        return null;
      }
      return CsvSkill(
        skillId: line[0],
        skillName: line[1],
        skillLevel: line[2],
      );
    }).where((e) => e != null);

    entries
        .sorted(
          (a, b) => a!.skillId < b!.skillId ? -1 : 1,
        )
        .forEach(
          (skill) => updateCharacterSkill(
            character: character,
            skillId: skill!.skillId,
            level: skill.skillLevel,
          ),
        );
  }

  Future<void> importSkillsFromFile(
    String filePath,
    Emitter<CharacterProfileState> emit,
  ) async {
    final file = File(filePath);
    final character = characterRepository.getCharacter(characterId)!;

    if (!file.existsSync()) {
      emit(ShowStatusUpdate('Cannot open file'));
    }

    final data = await file.readAsString();
    loadCharacterFromCsv(data: data, character: character);

    emit(ShowStatusUpdate('Skills updated'));
    emit(CharacterProfileUpdated(
      character: character,
      skillGroups: skillGroups as List<Group>,
    ));
  }

  Future<void> exportSkillsToFile(
    String filePath,
    Emitter<CharacterProfileState> emit,
  ) async {
    // TODO: This should be static to the BLOC!
    final character = characterRepository.getCharacter(characterId)!;
    final file = File('$filePath/${character.name}.csv');
    final learntSkills = {for (var s in character.learntSkills) s.skillId: s};
    final csvItems = skills.map((skill) {
      final learntSkill = learntSkills[skill.id];
      final skillName = localisationRepository.getLocalisedNameForItem(skill);
      return CsvSkill(
        skillId: skill.id,
        skillName: skillName,
        skillLevel: learntSkill?.skillLevel ?? 0,
      );
    }).map((e) => e.toString());

    final lines = [CsvSkill.csvHeader, ...csvItems].join('\n');
    await file.writeAsString(lines, mode: FileMode.write, flush: true);
    emit(ShowStatusUpdate('File written to ${file.path}'));
    emit(CharacterProfileUpdated(
      character: character,
      skillGroups: skillGroups as List<Group>,
    ));
  }
}

class CsvSkill {
  final int skillId;
  final String skillName;
  final int skillLevel;

  CsvSkill({
    required this.skillId,
    required this.skillName,
    required this.skillLevel,
  });

  @override
  String toString() {
    return [skillId, skillName, skillLevel].join(',');
  }

  static String get csvHeader => 'ID,Name,Level';
}
