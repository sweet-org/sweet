
import 'fitting_item.dart';

final regexBasic = RegExp(r"^/Skill/.+/Basic/.+$");
final regexAdvanced = RegExp(r"^/Skill/.+/Advan/.+$");
final regexExpert = RegExp(r"^/Skill/.+/Speci/.+$");

class FittingSkill extends FittingItem {
  final int skillLevel;
  SkillLevelType? _levelType;
  SkillLevelType? get levelType => _levelType;

  FittingSkill({
    required this.skillLevel,
    required super.item,
    required super.baseAttributes,
    required super.modifiers,
  }) {
    findLevelType();
  }

  FittingSkill copyWith({required int skillLevel}) => FittingSkill(
        skillLevel: skillLevel,
        item: item,
        baseAttributes: baseAttributes,
        modifiers: modifiers,
      );

  void findLevelType() {
    if (item.mainCalCode == null) {
      print("Skill ${item.id} has no main cal code");
      return;
    }
    if (regexBasic.hasMatch(item.mainCalCode ?? "")) {
      _levelType = SkillLevelType.basic;
    } else if (regexAdvanced.hasMatch(item.mainCalCode ?? "")) {
      _levelType = SkillLevelType.advanced;
    } else if (regexExpert.hasMatch(item.mainCalCode ?? "")) {
      _levelType = SkillLevelType.expert;
    } else {
      // print("Skill ${item.id} has unknown main cal code ${item.mainCalCode}");
    }
  }

}

enum SkillLevelType {
  basic,
  advanced,
  expert
}
