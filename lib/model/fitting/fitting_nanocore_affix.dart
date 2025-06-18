import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:sweet/database/database_exports.dart';

import 'fitting_item.dart';

class FittingNanocoreAffixItem extends FittingItem {
  final ItemNanocoreAffix affix;

  int get level => affix.attrLevel;

  final List<ItemModifier> passiveModifiers;

  FittingNanocoreAffixItem({
    required this.affix,
    required super.baseAttributes,
    required super.modifiers,
    required this.passiveModifiers,
  }) : super(
            item: affix.item!);
}

class FittingNanocoreAffix with EquatableMixin {
  int _selectedLevel = 0;

  final Map<int, FittingNanocoreAffixItem> levels;
  late final int _groupLevel;

  FittingNanocoreAffixItem get item => levels[_selectedLevel]!;

  int get selectedLevel => _selectedLevel;
  int get affixGroup => item.affix.attrGroup;

  FittingNanocoreAffixItem get selected => levels[_selectedLevel]!;

  void selectLevel(int newLevel) {
    _selectedLevel = newLevel;
  }

  /* ToDo: I don't know why it is like that, every modifier has two effects
           (called Min/Max), that do the same

   */
  List<String> get passiveMainCalCode => [item.passiveModifiers.first.code];

  List<String> get mainCalCode => [item.mainCalCode.first, ...passiveMainCalCode];

  // List<String> get activeCalCode => [item.activeCalCode.first];

  List<Attribute> get baseAttributes => [item.baseAttributes.first];

  List<ItemModifier> get modifiers => [
    item.modifiers.first, ...passiveModifiers
  ];

  List<ItemModifier> get passiveModifiers => [
    item.passiveModifiers.first
  ];

  List<int> get availableLevels =>
      levels.values.map((e) => e.level).sorted((a, b) => a - b).toList();

  FittingNanocoreAffix(this.levels) {
    _groupLevel = levels[0]!.itemId;
  }

  @override
  List<Object?> get props => [_groupLevel];
}
