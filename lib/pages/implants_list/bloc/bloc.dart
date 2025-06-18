import 'package:bloc/bloc.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/item_repository.dart';

import '../../../model/implant/implant_fitting_loadout.dart';
import 'events.dart';
import 'states.dart';

class ImplantFittingBrowserBloc
    extends Bloc<ImplantFittingBrowserEvent, ImplantFittingBrowserState> {
  final ImplantFittingLoadoutRepository fittingRepository;
  final ItemRepository itemRepository;

  ImplantFittingBrowserBloc(
      {required this.fittingRepository, required this.itemRepository})
      : super(ImplantFittingBrowserLoaded(fittingRepository.implants)) {
    on<ImplantFittingBrowserEvent>((event, emit) => mapEventToState(event, emit));
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
      ImplantFittingBrowserEvent event,
      Emitter<ImplantFittingBrowserState> emit,
      ) async {
    if (event is CreateImplantFitting) {
      emit(ImplantFittingBrowserLoading());
      var definition =
      await itemRepository.getImplantLoadoutDefinition(event.implant.id);
      var loadout =
      ImplantFittingLoadout.fromDefinition(event.implant.id, definition);

      await fittingRepository.addImplant(loadout);
      emit(ImplantFittingBrowserLoaded(fittingRepository.implants));
    }

    if (event is DeleteImplantFitting) {
      emit(ImplantFittingBrowserLoading());
      await fittingRepository.deleteImplant(loadoutId: event.implantFittingId);
      emit(ImplantFittingBrowserLoaded(fittingRepository.implants));
    }

    if (event is LoadAllImplantFittings) {
      emit(ImplantFittingBrowserLoading());
      await fittingRepository.loadImplants();
      emit(ImplantFittingBrowserLoaded(fittingRepository.implants));
    }

    if (event is ReorderImplantFitting) {
      emit(ImplantFittingBrowserLoading());
      await fittingRepository.moveImplant(
          element: event.element,
          newIndex: event.newIndex,
      );
      emit(ImplantFittingBrowserLoaded(fittingRepository.implants));
    }
  }
}
