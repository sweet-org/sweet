import 'package:bloc/bloc.dart';
import 'package:sweet/database/entities/market_group.dart';
import 'package:sweet/repository/item_repository.dart';

import './item_repository_events.dart';
import './item_repository_states.dart';

class ItemRepositoryBloc
    extends Bloc<ItemRepositoryEvent, ItemRepositoryState> {
  final ItemRepository _itemRepository;

  ItemRepositoryBloc(
    this._itemRepository,
  ) : super(InitialRepositoryState()) {
    on<ItemRepositoryEvent>((event, emit) => mapEventToState(event, emit));
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    ItemRepositoryEvent event,
    Emitter<ItemRepositoryState> emit,
  ) async {
    if (event is FetchItemCategories) {
      emit(LoadingRepositoryState());
      var filtered = await _itemRepository.categories();
      emit(FilteredItemCategories(filteredCategories: filtered));
    }

    if (event is FilterItems) {
      if (event.filterString.isEmpty) {
        emit(LoadingRepositoryState());
        var filtered = await _itemRepository.categories();
        emit(FilteredItemCategories(filteredCategories: filtered));
      } else {
        var filteredItems = await _itemRepository.itemsFilteredOnName(
          filter: event.filterString.toLowerCase(),
        );

        emit(FilteredItems(filteredItems: filteredItems));
      }
    }

    if (event is FetchMarketGroups) {
      emit(FilteredMarketGroups(
          filteredMarketGroups: _itemRepository.marketGroupMap.values
              .where((element) => element.parentId == null)));
    }

    if (event is FilterMarketGroups) {
      if (event.filterString.isEmpty) {
        emit(FilteredMarketGroups(
            filteredMarketGroups: _itemRepository.marketGroupMap.values
                .where((element) => element.parentId == null)));
      } else {
        // Get all the items fitting the filter
        var filteredItems = await _itemRepository.itemsFilteredOnName(
          filter: event.filterString.toLowerCase(),
        );

        // map into their market groups
        var thirdGroup = filteredItems
            .map((e) => _itemRepository.marketGroupMap[e.marketGroupId])
            .toSet()
            .where((e) => e != null)
            .map((e) => MarketGroup.clone(
                  e!,
                  [],
                  filteredItems.where((f) => f.marketGroupId == e.id).toList(),
                ));

        var secondGroup = thirdGroup
            .map((e) {
              var parentId = (e.id / 100).floor();
              return _itemRepository.marketGroupMap[parentId];
            })
            .toSet()
            .where((e) => e != null)
            .map((e) => MarketGroup.clone(
                e!,
                thirdGroup.where((f) => (f.id / 100).floor() == e.id).toList(),
                []));

        var topGroups = secondGroup
            .map((e) {
              var parentId = (e.id / 1000).floor();
              return _itemRepository.marketGroupMap[parentId];
            })
            .toSet()
            .where((e) => e != null)
            .map((e) => MarketGroup.clone(
                e!,
                secondGroup
                    .where((f) => (f.id / 1000).floor() == e.id)
                    .toList(),
                []))
            .toList();

        topGroups.sort((a, b) => a.id < b.id ? -1 : 1);

        emit(FilteredMarketGroups(filteredMarketGroups: topGroups));
      }
    }
  }
}
