import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../repository/character_repository.dart';
import 'learned_skill.dart';

part 'character.g.dart';

List<Character> charactersFromJson(String str) =>
    List<Character>.from(jsonDecode(str).map((x) => Character.fromJson(x)));

@JsonSerializable()
class Character extends ChangeNotifier {
  static String get defaultName => 'Unnamed Character';

  late String _id;
  String get id => _id;
  late String _name;
  String get name => _name;
  int _totalImplantLevels = 0;
  int get totalImplantLevels => _totalImplantLevels;
  String? csvLink;
  late List<LearnedSkill> learntSkills;

  Character({
    String? id,
    required String name,
    int? totalImplantLevels,
    List<LearnedSkill>? learntSkills,
    this.csvLink,
  }) {
    _id = id ?? Uuid().v1();
    _name = name;
    _totalImplantLevels = totalImplantLevels ?? 0;
    this.learntSkills = learntSkills ?? [];
  }

  static Character get empty => Character(
      id: CharacterRepository.noSkillCharacterId,
      name: 'No Skills',
      learntSkills: []);

  void setName(String newName, {bool notify = true}) {
    _name = newName;
    if (notify) notifyListeners();
  }

  void setTotalImplantLevels(int totalImplantLevels, {bool notify = true}) {
    _totalImplantLevels = totalImplantLevels;
    notifyListeners();
    if (notify) notifyListeners();
  }

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);

  Character copyWithName(String name) => Character(
      name: name, learntSkills: learntSkills.map((e) => e.copy()).toList());

  void updateSkill({required int id, required int level}) {
    final skill =
        learntSkills.firstWhere((skill) => skill.skillId == id, orElse: () {
      final newSkill = LearnedSkill(skillId: id);
      learntSkills.add(newSkill);
      return newSkill;
    });

    skill.setSkillLevel(level);

    notifyListeners();
  }

  factory Character.fromQrCodeData(String qrCodeData) {
    var data = base64.decode(qrCodeData);
    var decompressed = BZip2Decoder().decodeBytes(data);
    var json = utf8.decode(decompressed);
    return Character.fromJson(jsonDecode(json));
  }

  String generateQrCodeData() {
    var jsonData = utf8.encode(jsonEncode(this));
    var compressed = BZip2Encoder().encode(jsonData);
    return base64.encode(compressed);
  }
}
