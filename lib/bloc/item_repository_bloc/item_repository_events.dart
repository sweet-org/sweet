import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class ItemRepositoryEvent extends Equatable {
  @override
  List<Object> get props => [];
  ItemRepositoryEvent([List props = const []]) : super();
}

class FetchItemCategories extends ItemRepositoryEvent {
  final bool includeEmpty;

  @override
  List<Object> get props => [includeEmpty];

  FetchItemCategories({this.includeEmpty = false});
}

class FetchMarketGroups extends ItemRepositoryEvent {
  @override
  List<Object> get props => [];
}

class FilterMarketGroups extends ItemRepositoryEvent {
  final String filterString;

  FilterMarketGroups(this.filterString);

  @override
  List<Object> get props => [
        filterString,
      ];
}

class FilterItems extends ItemRepositoryEvent {
  final String filterString;

  FilterItems(this.filterString);

  @override
  List<Object> get props => [
        filterString,
      ];
}
