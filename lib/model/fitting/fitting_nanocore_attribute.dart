import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/item_modifier.dart';
import 'package:sweet/util/constants.dart';

import 'fitting_item.dart';

class FittingNanocoreAttribute with EquatableMixin {
  final FittingItem _item;
  late final List<NanocoreAttributeLevel> levels;
  NanocoreAttributeLevel? selectedLevel;

  ItemModifier? get selectedModifier => selectedLevel?.value;

  int get selectedLevelIndex {
    final level = selectedLevel;
    if (level == null) return -1;
    return levels.toList().indexOf(level);
  }

  bool get hasRange => minValue != maxValue;
  double get minValue => _item.modifiers.first.attributeValue;
  double get maxValue => _item.modifiers.last.attributeValue;

  Iterable<Attribute> get baseAttributes => _item.baseAttributes;
  Iterable<String> get mainCalCode => _item.mainCalCode;
  int get itemId => _item.itemId;
  int get attributeId => _item.modifiers.first.attributeId;
  int get changeRangeModuleNameId =>
      _item.modifiers.first.changeRangeModuleNameId;

  FittingNanocoreAttribute(this._item) {
    final step = (maxValue - minValue) / (kNanocoreWeights.length - 1);
    final weightSum = kNanocoreWeights.fold<int>(
      0,
      (previousValue, element) => previousValue + element,
    );

    if (maxValue.compareTo(minValue) == 0) {
      levels = [NanocoreAttributeLevel(value: _item.modifiers.first)];
    } else {
      levels = kNanocoreWeights.mapIndexed(
        (index, weight) {
          final value = (minValue + (index * step));
          final truncValue = double.tryParse(
                value.toStringAsFixed(4),
              ) ??
              value;
          return NanocoreAttributeLevel(
            value: _item.modifiers.first.copyWith(
              attributeValue: truncValue,
            ),
            chance: weight / weightSum,
          );
        },
      ).toList();
    }
  }

  @override
  List<Object?> get props => [
        _item.itemId,
      ];
}

class NanocoreAttributeLevel {
  final ItemModifier value;
  final double chance;

  const NanocoreAttributeLevel({
    required this.value,
    this.chance = 1.0,
  });
}
