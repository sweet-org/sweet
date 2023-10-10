import 'package:bloc/bloc.dart';
import 'package:sweet/model/ship/ship_fitting_folder.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';

import 'events.dart';
import 'states.dart';

class ShipFittingBrowserBloc
    extends Bloc<ShipFittingBrowserEvent, ShipFittingBrowserState> {
  final ShipFittingLoadoutRepository fittingRepository;
  final ItemRepository itemRepository;

  ShipFittingBrowserBloc(
      {required this.fittingRepository, required this.itemRepository})
      : super(ShipFittingBrowserLoaded(fittingRepository.loadouts)) {
    on<ShipFittingBrowserEvent>((event, emit) => mapEventToState(event, emit));
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    ShipFittingBrowserEvent event,
    Emitter<ShipFittingBrowserState> emit,
  ) async {
    if (event is CreateShipFitting) {
      emit(ShipFittingBrowserLoading());
      var shipLoadoutDefinition =
          await itemRepository.getShipLoadoutDefinition(event.ship.id);
      var loadout =
          ShipFittingLoadout.fromShip(event.ship.id, shipLoadoutDefinition);

      await fittingRepository.addLoadout(loadout);
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is CreateFittingFolder) {
      emit(ShipFittingBrowserLoading());
      var folder = ShipFittingFolder(name: "Unnamed Folder");
      await fittingRepository.addLoadout(folder);
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is RenameFittingFolder) {
      emit(ShipFittingBrowserLoading());
      event.folder.setName(event.newName);
      await fittingRepository.saveLoadouts();
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is MoveFittingToFolder) {
      emit(ShipFittingBrowserLoading());
      await fittingRepository.moveToFolder(
          loadout: event.fitting, folderId: event.folderId
      );
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is DeleteShipFitting) {
      emit(ShipFittingBrowserLoading());
      await fittingRepository.deleteLoadout(loadoutId: event.shipFittingId);
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is ImportShipFitting) {
      emit(ShipFittingBrowserLoading());
      await fittingRepository.addLoadout(event.shipFitting);
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is CloneShipFitting) {
      emit(ShipFittingBrowserLoading());
      final fitting = event.shipFitting.copyWithName(
        event.fittingName,
      );
      await fittingRepository.addLoadout(fitting);
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is LoadAllShipFittings) {
      emit(ShipFittingBrowserLoading());
      await fittingRepository.loadLoadouts();
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }

    if (event is ReorderShipFitting) {
      emit(ShipFittingBrowserLoading());
      await fittingRepository.moveFitting(
        element: event.element,
        newIndex: event.newIndex,
      );
      emit(ShipFittingBrowserLoaded(fittingRepository.loadouts));
    }
  }
}
