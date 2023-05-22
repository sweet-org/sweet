import 'package:collection/collection.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'fitting_nanocore_attribute_list.dart';

class FittingNanocore extends FittingModule {
  static const String kSelectableAttributeIdKey = 'selectableAttributeId';
  static const String kSelectedAttributeLevelKey = 'selectedAttributeLevel';
  static const String kTrainableAttributesKey = 'trainableAttributes';

  bool get isTrainable => trainableAttributes.isNotEmpty;
  final List<FittingNanocoreAttributeList> trainableAttributes;
  final FittingNanocoreAttributeList mainAttribute;

  @override
  Map<String, dynamic> get metadata => {
        kSelectableAttributeIdKey: mainAttribute.selectedAttribute?.itemId ?? 0,
        kTrainableAttributesKey: trainableAttributes
            .map((e) => {
                  kSelectableAttributeIdKey: e.selectedAttribute?.itemId ?? 0,
                  kSelectedAttributeLevelKey:
                      e.selectedAttribute?.selectedLevelIndex ?? -1,
                })
            .toList(),
      };

  @override
  List<ItemModifier> get modifiers {
    final mods = [
      mainAttribute.selectedModifier,
      ...trainableAttributes.map((e) => e.selectedModifier)
    ].whereNotNull().toList();

    return mods;
  }

  @override
  List<Attribute> get baseAttributes => [
        ...?mainAttribute.selectedAttribute?.baseAttributes,
        ...trainableAttributes
            .map((e) => e.selectedAttribute?.baseAttributes ?? [])
            .expand((e) => e),
      ].toList();

  @override
  List<String> get mainCalCode => [
        ...?mainAttribute.selectedAttribute?.mainCalCode,
        ...trainableAttributes
            .map((e) => e.selectedAttribute?.mainCalCode ?? [])
            .expand((e) => e),
      ].toList();

  @override
  FittingNanocore copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
  }) {
    return FittingNanocore(
      baseItem: item,
      index: index ?? this.index,
      mainAttribute: mainAttribute,
      trainableAttributes: trainableAttributes,
      metadata: metadata,
    );
  }

  factory FittingNanocore.fromItems({
    required Item baseItem,
    int index = 0,
    required Iterable<FittingItem> mainAttributes,
    required Iterable<Iterable<FittingItem>> trainableAttributes,
    required Map<String, dynamic> metadata,
  }) =>
      FittingNanocore(
        baseItem: baseItem,
        index: 0,
        mainAttribute: FittingNanocoreAttributeList(mainAttributes),
        trainableAttributes: trainableAttributes
            .map((e) => FittingNanocoreAttributeList(e))
            .toList(),
        metadata: metadata,
      );

  FittingNanocore({
    required Item baseItem,
    int index = 0,
    required this.mainAttribute,
    required this.trainableAttributes,
    required Map<String, dynamic> metadata,
  }) : super(
          item: baseItem,
          baseAttributes: [],
          modifiers: [],
          slot: SlotType.nanocore,
          index: index,
          state: ModuleState.inactive,
        ) {
    final mainAttributeId = metadata[kSelectableAttributeIdKey] as int? ?? 0;

    // Set the selected attribute
    // Main only have the single level?
    mainAttribute.selectAttributeById(mainAttributeId, 0);

    final trainableDetails = List<Map<String, dynamic>>.from(
      metadata[kTrainableAttributesKey] ?? [],
    );

    trainableDetails.forEachIndexed((index, dictionary) {
      if (index >= trainableAttributes.length) return;

      final attributeList = trainableAttributes.elementAt(index);
      final selectedId = dictionary[kSelectableAttributeIdKey] as int? ?? 0;
      final levelIndex = dictionary[kSelectedAttributeLevelKey] as int? ?? -1;

      attributeList.selectAttributeById(selectedId, levelIndex);
    });
  }
}
