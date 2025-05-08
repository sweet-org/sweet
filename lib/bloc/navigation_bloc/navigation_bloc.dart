import 'package:bloc/bloc.dart';

import 'navigation_bloc_events.dart';
import 'navigation_bloc_states.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(ResetRootState(RootPages.CharacterBrowser)) {
    on<NavigationEvent>((event, emit) => mapEventToState(event, emit));
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    NavigationEvent event,
    Emitter<NavigationState> emit,
  ) async {
    if (event is RequestNavigationRoute) {
      emit(PushNavigationRoute(event.route));
    }
    if (event is ShowSettingsPage) {
      emit(ResetRootState(RootPages.Settings));
    }
    if (event is ShowMarketBrowserPage) {
      emit(ResetRootState(RootPages.MarketBrowser));
    }
    if (event is ShowItemBrowserPage) {
      emit(ResetRootState(RootPages.ItemBrowser));
    }
    if (event is ShowCharacterBrowserPage) {
      emit(ResetRootState(RootPages.CharacterBrowser));
    }
    if (event is ShowFittingToolPage) {
      emit(ResetRootState(RootPages.FittingTool));
    }
    if (event is ShowImplantToolPage) {
      emit(ResetRootState(RootPages.ImplantFittings));
    }
    if (event is ShowPatchNotesPage) {
      emit(ResetRootState(RootPages.PatchNotes));
    }
  }
}
