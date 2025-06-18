

import 'package:bloc/bloc.dart';
import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/item_repository.dart';

import 'events.dart';
import 'states.dart';

class ImplantFittingBloc extends Bloc<ImplantFittingEvent, ImplantFittingState> {
  final ImplantHandler implant;

  final ItemRepository _itemRepository;
  final ImplantFittingLoadoutRepository fittingRepository;

  late Character _pilot;
  Character get pilot => _pilot;

  ImplantFittingBloc(this._itemRepository, this.fittingRepository, this.implant)
      : super(InitialImplantFitting(implant)) {
    on<ImplantFittingEvent>((event, emit) => mapEventToState(event, emit));
  }

  Future<void> mapEventToState(
      ImplantFittingEvent event,
      Emitter<ImplantFittingState> emit,
      ) async {
    emit(UpdatingImplantFitting(implant));

    if (event is ShowFittingsMenu) {
      await mapShowFittingMenuEvent(event, emit);
    }

    if (event is SaveImplantFitting) {
      if (!fittingRepository.implants.contains(implant.loadout)) {
        await fittingRepository.addImplant(implant.loadout);
      }

      await fittingRepository.saveImplants();
      emit(ImplantFittingUpdatedState(implant));
    }
  }

  Future<void> mapShowFittingMenuEvent(
      ShowFittingsMenu event,
      Emitter<ImplantFittingState> emit,
      ) async {
    MarketGroup group = MarketGroup.invalid;
    var initialItems = <Item>[];

    switch (event.slotType) {
      case ImplantSlotType.common:
        // General Units
        group = MarketGroup.clone(
            _itemRepository.marketGroupMap[MarketGroupFilters.implants.marketGroupId]!,
          [
            _itemRepository.marketGroupMap[MarketGroupFilters.generalUnits.marketGroupId]!,
            _itemRepository.marketGroupMap[MarketGroupFilters.advancedUnits.marketGroupId]!,
          ],
          null,
        );
        break;
      case ImplantSlotType.slaveCommon:
        // Slave Units
        group = MarketGroup.clone(
            _itemRepository.marketGroupMap[MarketGroupFilters.implants.marketGroupId]!,
          [
            _itemRepository.marketGroupMap[MarketGroupFilters.reactiveUnits.marketGroupId]!,
          ],
          null,
        );
        break;
      case ImplantSlotType.branch:
        // Normal Branches (Level 15 & 30)
      case ImplantSlotType.upgrade:
        // Level 45 Upgrade
        if (event.allowedItemIds == null) {
          print("Error: No allowed items provided for implant slot type branch/upgrade");
          break;
        }

        initialItems = await _itemRepository.itemsWithIds(
            ids: event.allowedItemIds!);
        break;
      case ImplantSlotType.disabled:
      default:
        print("Error: Invalid slot type ${event.slotType}");
        return;
    }

    emit(OpenContextDrawerState(
      group,
      initialItems,
      event.slotIndex,
      implant,
    ));
  }
}
