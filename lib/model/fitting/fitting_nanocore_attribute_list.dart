import 'package:collection/collection.dart';
import 'package:sweet/database/entities/item_modifier.dart';

import 'fitting_item.dart';
import 'fitting_nanocore_attribute.dart';

class FittingNanocoreAttributeList {
  final Iterable<FittingNanocoreAttribute> attributes;
  FittingNanocoreAttribute? _selectedAttribute;
  FittingNanocoreAttribute? get selectedAttribute => _selectedAttribute;

  FittingNanocoreAttributeList(Iterable<FittingItem> attributes)
      : attributes = attributes
            .map(
              (e) => FittingNanocoreAttribute(e),
            )
            .toList();

  ItemModifier? get selectedModifier => _selectedAttribute?.selectedModifier;

  // Should be FittingItem?
  void selectAttribute(
    FittingNanocoreAttribute? attribute, {
    NanocoreAttributeLevel? level,
  }) {
    _selectedAttribute?.selectedLevel = null;
    _selectedAttribute = attribute;
    _selectedAttribute?.selectedLevel = level;
  }

  void selectAttributeById(int id, int levelIndex) {
    final attribute = attributes.firstWhereOrNull((item) => item.itemId == id);

    selectAttribute(
      attribute,
      level: attribute?.levels.elementAt(levelIndex),
    );
  }
}
