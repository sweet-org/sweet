import 'package:collection/collection.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/item_modifier.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/model/ship/slot_type.dart';

class FittingRigIntegrator extends FittingModule {
  static const String kSelectedRigItemIdsKey = 'selectedRigItemIds';
  static final mainCalCodeRegex = RegExp('(/([^/]*))');

  @override
  int get groupKey => _selectedRigs.fold<int>(
        itemId,
        (previous, next) => previous + next.itemId,
      );

  List<FittingModule> _selectedRigs = [];
  Iterable<FittingModule> get integratedRigs =>
      _selectedRigs.where((rig) => rig != FittingModule.empty);

  int? get integrationMarketGroupId => _selectedRigs
      .firstWhereOrNull(
        (m) => m != FittingModule.empty,
      )
      ?.marketGroupId;

  Iterable<String> get integratedModifierGroups => _selectedRigs
      .map((e) => e.modifiers)
      .expand((i) => i)
      .where(
        (m) => !kIgnoreAttributeIds.contains(m.attributeId),
      )
      .map((e) => e.typeCode);

  int get numberOfSlots {
    final attribute = super.baseAttributes.firstWhereOrNull(
          (a) => a.id == EveEchoesAttribute.integrationSlotNumber.attributeId,
        );

    if (attribute == null) {
      print('Item $itemId does not have attribute integrationSlotNumber');
      return 0;
    }

    return attribute.baseValue.toInt();
  }

  int get numberOfMaterials {
    final attribute = super.baseAttributes.firstWhereOrNull(
          (a) =>
              a.id ==
              EveEchoesAttribute.integrationMaterialMultiplier.attributeId,
        );

    if (attribute == null) {
      print(
        'Item $itemId does not have attribute integrationMaterialMultiplier',
      );
      return 0;
    }
    return attribute.baseValue.toInt();
  }

  double get integrationMultiplier {
    final attribute = super.baseAttributes.firstWhereOrNull(
          (a) => a.id == EveEchoesAttribute.integrationEfficiency.attributeId,
        );

    if (attribute == null) {
      print('Item $itemId does not have attribute integrationEfficiency');
      return 1.0;
    }

    return attribute.baseValue;
  }

  @override
  Map<String, dynamic> get metadata => {
        kSelectedRigItemIdsKey: _selectedRigs.map((rig) => rig.itemId).toList(),
      };

  @override
  List<ItemModifier> get modifiers {
    // NOTE: This may need future changes - if it is ever adjustable
    final mods = super
        .modifiers
        .map(
          (e) => e.copyWith(attributeValue: e.attributeValue),
        )
        .toList();

    _selectedRigs
        .map((e) => e.modifiers)
        .expand((i) => i)
        .where(
          (m) => !kIgnoreAttributeIds.contains(m.attributeId),
        )
        .forEach((m) {
      mods.add(m.copyWith(
        attributeValue: m.attributeValue * integrationMultiplier,
      ));
    });

    return mods.toList();
  }

  @override
  List<Attribute> get baseAttributes {
    final b = super.baseAttributes.map((e) => e.copyWith()).toList();
    final att = {for (var a in b) a.id: a};

    _selectedRigs
        .map((e) => e.baseAttributes)
        .expand((i) => i)
        .where(
          (a) => !att.containsKey(a.id) && !kIgnoreAttributeIds.contains(a.id),
        )
        .forEach((a) {
      if (a.id != EveEchoesAttribute.moduleCanFitAttributeID.attributeId) {
        att[a.id] = a.copyWith(
          baseValue: a.baseValue * integrationMultiplier,
        );
      } else {
        att[a.id] = a.copyWith(
          baseValue: a.baseValue,
        );
      }
    });

    return att.values.toList();
  }

  @override
  List<String> get mainCalCode {
    return [
      ...super.mainCalCode,
      ..._selectedRigs.map((e) => e.mainCalCode).expand((e) => e),
    ];
  }

  @override
  List<String> get activeCalCode => [''];

  @override
  FittingRigIntegrator copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
    bool? isDroneModule = false,
  }) {
    if (isDroneModule != null && isDroneModule) {
      throw UnimplementedError(
        'Drone modules are not supported yet for integrated rigs',
      );
    }
    return FittingRigIntegrator(
      baseItem: super.item,
      baseAttributes: super.baseAttributes,
      modifiers: super.modifiers,
      selectedRigs: _selectedRigs,
      slot: slot ?? this.slot,
      index: index ?? this.index,
    );
  }

  FittingRigIntegrator({
    required Item baseItem,
    required super.baseAttributes,
    required super.modifiers,
    required List<FittingModule> selectedRigs,
    super.slot = SlotType.combatRig,
    super.index,
  }) : super(
          item: baseItem,
          state: ModuleState.inactive,
        ) {
    // if (selectedRigs.isEmpty) {
    //   _selectedRigs = List.filled(numberOfSlots, FittingModule.empty);
    // } else if (selectedRigs.length < numberOfSlots) {
    _selectedRigs = [
      ...selectedRigs,
      ...List.filled(
        numberOfSlots - selectedRigs.length,
        FittingModule.empty,
      )
    ];
    // } else {
    //   _selectedRigs = selectedRigs;
    // }
  }

  @override
  List<Object> get props => [
        itemId,
        state,
        ..._selectedRigs.map((e) => e.itemId),
      ];

  bool canFit({required FittingModule rig}) {
    final fittedRig =
        _selectedRigs.firstWhereOrNull((m) => m != FittingModule.empty);
    if (fittedRig != null) {
      return rig.groupId == fittedRig.groupId && rig.itemId != fittedRig.itemId;
    }

    return rig.rootMarketGroupId == rootMarketGroupId;
  }

  void fit({required FittingModule rig, required int index}) {
    if (index >= numberOfSlots) return;

    _selectedRigs[index] = rig.copyWith(slot: slot, index: index);
  }

  int? findEmptySlot() {
    for (int i = 0; i < _selectedRigs.length; i++) {
      if (_selectedRigs[i] == FittingModule.empty) {
        return i;
      }
    }
    return null;
  }

  FittingModule rigAtIndex(int index) {
    if (_selectedRigs.length < index) return FittingModule.empty;
    return _selectedRigs[index];
  }
}
