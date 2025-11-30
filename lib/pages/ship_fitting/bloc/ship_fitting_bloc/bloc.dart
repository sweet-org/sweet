import 'package:bloc/bloc.dart';
import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';

import 'events.dart';
import 'states.dart';

class ShipFittingBloc extends Bloc<ShipFittingEvent, ShipFittingState> {
  final FittingSimulator fitting;

  final ItemRepository _itemRepository;
  final ShipFittingLoadoutRepository fittingRepository;
  final ImplantFittingLoadoutRepository implantRepository;

  late Character _pilot;

  Character get pilot => _pilot;

  ShipFittingBloc(this._itemRepository, this.fittingRepository,
      this.implantRepository, this.fitting)
      : super(InitialShipFitting(fitting)) {
    on<ShipFittingEvent>((event, emit) => mapEventToState(event, emit));
  }

  MarketGroupFilters filterForSlot(SlotType slotType) =>
      slotType.marketGroupFilter;

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    ShipFittingEvent event,
    Emitter<ShipFittingState> emit,
  ) async {
    emit(UpdatingShipFitting(fitting));
    if (event is ShowFittingsMenu) {
      await mapShowFittingMenuEvent(event, emit);
    }

    if (event is ShowRigIntegrationMenu) {
      await mapShowRigIntegrationMenu(event, emit);
    }

    if (event is ShowNanocoreAffixMenu) {
      await mapShowNanocoreAffixMenu(event, emit);
    }

    if (event is ChangePilotForFitting) {
      emit(OpenPilotDrawerState(fitting));
    }

    if (event is ChangeDamagePatternForFitting) {
      emit(OpenDamagePatternDrawerState(fitting));
    }

    if (event is ShowShipFittingStats) {
      emit(OpenFittingStatsDrawerState(fitting));
    }

    if (event is SaveShipFitting) {
      if (!fittingRepository.loadouts.contains(fitting.loadout)) {
        await fittingRepository.addLoadout(fitting.loadout);
      }

      await fittingRepository.saveLoadouts();
      emit(ShipFittingUpdatedState(fitting));
    }
  }

  Future<void> mapShowFittingMenuEvent(
    ShowFittingsMenu event,
    Emitter<ShipFittingState> emit,
  ) async {
    var filter = filterForSlot(event.slotType);
    MarketGroup group;
    var childGroups = <int>[];  // Only for lightweight ships
    var initialItems = <Item>[];

    switch (event.slotType) {
      case SlotType.implantSlots:
        emit(OpenImplantDrawer(fitting: fitting, slotIndex: event.slotIndex!));
        return;
      case SlotType.drone:
        {
          // Because Drones are buried under Mid Slot..
          // Fighters are a thing now too - which makes this messy
          final midSlot = _itemRepository
              .marketGroupMap[MarketGroupFilters.midSlot.marketGroupId]!;
          group = MarketGroup.clone(
            midSlot,
            midSlot.children
                .where(
                  (e) =>
                      e.id == MarketGroupFilters.drones.marketGroupId ||
                      e.id == MarketGroupFilters.fighters.marketGroupId,
                )
                .toList(),
            null,
          );
          break;
        }

      case SlotType.nanocore:
        {
          // Nanocores are ship specific
          // So we need to only have the ones that are for the current ship
          group = MarketGroup.invalid;
          final shipId = fitting.ship.itemId;
          final filteredCoreIds = await _itemRepository.db.itemNanocoreDao
              .select(
                whereClause: 'WHERE availableShips LIKE "%$shipId%"',
              )
              .then((cores) => cores.map((e) => e.itemId));
          initialItems = await _itemRepository.itemsWithIds(
            ids: filteredCoreIds.toList(),
          );
          break;
        }

      // The rule is, smaller ships can be fitted into larger slots, so we want
      // to fallthrough all following cases (which dart does not allow -_-)
      case SlotType.lightBCSlot:
        childGroups.add(MarketGroupFilters.lightweightBattlecruisers.marketGroupId);
        continue lightCAModules;
      lightCAModules:
      case SlotType.lightCASlot:
        childGroups.add(MarketGroupFilters.lightweightCruisers.marketGroupId);
        continue lightDDModules;
      lightDDModules:
      case SlotType.lightDDSlot:
        childGroups.add(MarketGroupFilters.lightweightDestroyers.marketGroupId);
        continue lightFFModules;
      lightFFModules:
      case SlotType.lightFFSlot:
        childGroups.add(MarketGroupFilters.lightweightFrigates.marketGroupId);
        final baseGroup = _itemRepository
            .marketGroupMap[MarketGroupFilters.fighters.marketGroupId]!;
        group = MarketGroup.clone(
          baseGroup,
          baseGroup.children.where((g) => childGroups.contains(g.id)).toList(),
          null
        );
        initialItems = [];
        break;

      // These ones are for Items only
      case SlotType.hangarRigSlots:
        group = _itemRepository.marketGroupMap[filter.marketGroupId]!;
        initialItems = group.items ?? [];
        break;
      case SlotType.defenceRigSlots:
        group = _itemRepository.marketGroupMap[filter.marketGroupId]!;
        initialItems = group.items ?? [];
        break;
      // We fall through here, and deal with any exclusions
      // which at present are only on Midslots and CombatRigs
      case SlotType.high:
        if (fitting.ship.marketGroupId ==
            MarketGroupFilters.pos.marketGroupId) {
          group = _itemRepository.marketGroupMap[
              MarketGroupFilters.structureWeapons.marketGroupId]!;
          initialItems = group.items ?? [];
          break;
        } else {
          // This is not very nice
          continue normalModules;
        }
      case SlotType.mid:
        if (fitting.ship.marketGroupId ==
            MarketGroupFilters.pos.marketGroupId) {
          group = _itemRepository.marketGroupMap[
              MarketGroupFilters.structureModules.marketGroupId]!;
          initialItems = group.items ?? [];
          break;
        } else {
          continue normalModules;
        }
      case SlotType.low:
        if (fitting.ship.marketGroupId ==
            MarketGroupFilters.pos.marketGroupId) {
          group = _itemRepository.marketGroupMap[
              MarketGroupFilters.structureServices.marketGroupId]!;
          initialItems = group.items ?? [];
          break;
        } else {
          continue normalModules;
        }
      case SlotType.combatRig:
      normalModules:
      case SlotType.engineeringRig:
        {
          group = _itemRepository.marketGroupMap[filter.marketGroupId]!;

          // Same deal here to strip them out
          if (event.slotType == SlotType.mid ||
              event.slotType == SlotType.combatRig) {
            group = MarketGroup.clone(
              group,
              group.children
                  .where(
                    (e) =>
                        e.id != MarketGroupFilters.drones.marketGroupId &&
                        e.id != MarketGroupFilters.fighters.marketGroupId &&
                        e.id !=
                            MarketGroupFilters.lightweightShips.marketGroupId &&
                        e.id !=
                            MarketGroupFilters.shipSystemsModRigs.marketGroupId
                  )
                  .toList(),
              null,
            );
          }
          break;
        }
    }

    //ToDo: This handle the exception when trying to open the nanocore list for a ship that does not have any

    emit(OpenContextDrawerState(
      group,
      initialItems,
      event.slotType,
      event.slotIndex,
      fitting,
    ));
  }

  Future<void> mapShowRigIntegrationMenu(
    ShowRigIntegrationMenu event,
    Emitter<ShipFittingState> emit,
  ) async {
    var initialItems = <Item>[];

    final group = (_itemRepository.marketGroupMap[event.parentMarketGroupId] ??
        MarketGroup.invalid);
    final parentMarketGroupId = event.rigIntegrator.marketGroupId ~/ 100;
    final filteredGroup = MarketGroup.clone(
      group,
      group.children.where((g) => g.id != parentMarketGroupId).toList(),
      null,
    );

    final filterMarketId = event.rigIntegrator.integrationMarketGroupId;
    if (filterMarketId != null) {
      final integratedModifierGroups =
          event.rigIntegrator.integratedModifierGroups;
      final items = _itemRepository.marketGroupMap[filterMarketId]?.items ?? [];
      initialItems = items.where(
        (item) {
          return !integratedModifierGroups.any(
            (modifierCode) =>
                item.mainCalCode?.startsWith(modifierCode) ?? false,
          );
        },
      ).toList();
    }
    // Filter out non integratable rigs
    initialItems = initialItems
        .where((item) => !_itemRepository.excludeFusionRigs
            .any((itemId) => item.id == itemId))
        .toList();
    emit(OpenRigIntegratorDrawer(
        rigIntegrator: event.rigIntegrator,
        topGroup: filteredGroup,
        initialItems: initialItems,
        slotIndex: event.slotIndex,
        fitting: fitting,
        blacklistItems: _itemRepository.excludeFusionRigs));
  }

  Future<void> mapShowNanocoreAffixMenu(
    ShowNanocoreAffixMenu event,
    Emitter<ShipFittingState> emit,
  ) async {
    emit(OpenNanocoreAffixDrawer(
        topClasses: _itemRepository.goldAttrFirstClassMap.values.toList(),
        initialItems: [],
        slotIndex: event.slotIndex,
        active: event.active,
        fitting: fitting));
  }
}
