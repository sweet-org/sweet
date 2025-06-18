import 'package:collection/collection.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'fitting_nanocore_affix.dart';
import 'fitting_nanocore_attribute_list.dart';

class FittingNanocore extends FittingModule {
  static const String kSelectableAttributeIdKey = 'selectableAttributeId';
  static const String kSelectableSecondAttributeIdKey =
      'selectableSecondAttributeId';
  static const String kSelectedAttributeLevelKey = 'selectedAttributeLevel';
  static const String kTrainableAttributesKey = 'trainableAttributes';
  static const String kAffixesKey = 'affixes';
  static const String kAffixesPassiveKey = 'affixesPassive';

  bool get isTrainable => trainableAttributes.isNotEmpty;
  final List<FittingNanocoreAttributeList> trainableAttributes;
  final FittingNanocoreAttributeList mainAttribute;
  final FittingNanocoreAttributeList? secondMainAttribute;
  final bool isGolden;
  final List<FittingNanocoreAffix?> extraAffixes = [];
  final List<FittingNanocoreAffix?> passiveAffixes = [null];

  List<FittingNanocoreAffix?> getAffixes(bool active) =>
      active ? extraAffixes : passiveAffixes;

  bool hasAffix(int groupId, {bool includePassive=true}) {
    if (extraAffixes.whereNotNull().any((e) => e.affixGroup == groupId)) {
      return true;
    }
    if (!includePassive) return false;
    return passiveAffixes.whereNotNull().any((e) => e.affixGroup == groupId);
  }

  @override
  Map<String, dynamic> get metadata => {
        kSelectableAttributeIdKey: mainAttribute.selectedAttribute?.itemId ?? 0,
        kSelectableSecondAttributeIdKey:
            secondMainAttribute?.selectedAttribute?.itemId ?? 0,
        kTrainableAttributesKey: trainableAttributes
            .map((e) => {
                  kSelectableAttributeIdKey: e.selectedAttribute?.itemId ?? 0,
                  kSelectedAttributeLevelKey:
                      e.selectedAttribute?.selectedLevelIndex ?? -1,
                })
            .toList(),
        kAffixesKey: extraAffixes.map((e) => e?.selected.itemId).toList(),
        kAffixesPassiveKey: passiveAffixes
            .whereNotNull()
            .map((e) => e.selected.itemId)
            .toList(),
      };

  @override
  List<ItemModifier> get modifiers {
    final mods = [
      mainAttribute.selectedModifier,
      secondMainAttribute?.selectedModifier,
      ...trainableAttributes.map((e) => e.selectedModifier),
      ...extraAffixes.whereNotNull().map((e) => e.modifiers).expand((e) => e),
      ...passiveAffixes
          .whereNotNull()
          .map((e) => e.passiveModifiers)
          .expand((e) => e),
    ].whereNotNull().toList();

    return mods;
  }

  @override
  List<Attribute> get baseAttributes => [
        ...?mainAttribute.selectedAttribute?.baseAttributes,
        ...?secondMainAttribute?.selectedAttribute?.baseAttributes,
        ...trainableAttributes
            .map((e) => e.selectedAttribute?.baseAttributes ?? [])
            .expand((e) => e),
        ...extraAffixes
            .whereNotNull()
            .map((e) => e.baseAttributes)
            .expand((e) => e),
        ...passiveAffixes
            .whereNotNull()
            .map((e) => e.baseAttributes)
            .expand((e) => e),
      ].toList();

  @override
  List<String> get mainCalCode => [
        ...?mainAttribute.selectedAttribute?.mainCalCode,
        ...?secondMainAttribute?.selectedAttribute?.mainCalCode,
        ...trainableAttributes
            .map((e) => e.selectedAttribute?.mainCalCode ?? [])
            .expand((e) => e),
        ...extraAffixes
            .whereNotNull()
            .map((e) => e.mainCalCode)
            .expand((e) => e),
        ...passiveAffixes
            .whereNotNull()
            .map((e) => e.passiveMainCalCode)
            .expand((e) => e),
      ].toList();

  @override
  FittingNanocore copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
    bool? isDroneModule = false,
  }) {
    if (isDroneModule != null && isDroneModule) {
      throw UnimplementedError(
        'Drone modules are not supported yet for nanocores',
      );
    }
    return FittingNanocore(
      baseItem: item,
      isGolden: isGolden,
      index: index ?? this.index,
      mainAttribute: mainAttribute,
      secondMainAttribute: secondMainAttribute,
      trainableAttributes: trainableAttributes,
      extraAffixes: extraAffixes,
      passiveAffixes: passiveAffixes,
      metadata: metadata,
    );
  }

  factory FittingNanocore.fromItems({
    required Item baseItem,
    int index = 0,
    required bool isGolden,
    required Iterable<FittingItem> mainAttributes,
    required Iterable<Iterable<FittingItem>> trainableAttributes,
    Iterable<FittingNanocoreAffix?>? affixes,
    Iterable<FittingNanocoreAffix?>? passiveAffixes,
    required Map<String, dynamic> metadata,
  }) =>
      FittingNanocore(
        baseItem: baseItem,
        index: 0,
        isGolden: isGolden,
        mainAttribute: FittingNanocoreAttributeList(mainAttributes),
        secondMainAttribute:
            isGolden ? FittingNanocoreAttributeList(mainAttributes) : null,
        trainableAttributes: trainableAttributes
            .map((e) => FittingNanocoreAttributeList(e))
            .toList(),
        extraAffixes: affixes,
        passiveAffixes: passiveAffixes,
        metadata: metadata,
      );

  FittingNanocore({
    required Item baseItem,
    super.index,
    required this.isGolden,
    required this.mainAttribute,
    this.secondMainAttribute,
    required this.trainableAttributes,
    Iterable<FittingNanocoreAffix?>? extraAffixes,
    Iterable<FittingNanocoreAffix?>? passiveAffixes,
    required Map<String, dynamic> metadata,
  }) : super(
          item: baseItem,
          baseAttributes: [],
          modifiers: [],
          slot: SlotType.nanocore,
          state: ModuleState.inactive,
        ) {
    final mainAttributeId = metadata[kSelectableAttributeIdKey] as int? ?? 0;
    final secondAttributeId =
        metadata[kSelectableSecondAttributeIdKey] as int? ?? 0;

    // Set the selected attribute
    // Main only have the single level?
    mainAttribute.selectAttributeById(mainAttributeId, 0);
    if (secondMainAttribute != null) {
      secondMainAttribute!.selectAttributeById(secondAttributeId, 0);
    }
    if (extraAffixes != null) this.extraAffixes.addAll(extraAffixes);

    // Golden Nanocore affixes
    if (this.extraAffixes.length < 4) {
      for (var i = this.extraAffixes.length; i < 4; i++) {
        this.extraAffixes.add(null);
      }
    }

    if (passiveAffixes != null) {
      this.passiveAffixes.clear();
      this.passiveAffixes.addAll(passiveAffixes);
    }
    if (!this.passiveAffixes.any((e) => e == null)) {
      this.passiveAffixes.add(null);
    }

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
