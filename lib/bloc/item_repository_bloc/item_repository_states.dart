import 'package:sweet/database/entities/category.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/market_group.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ItemRepositoryState extends Equatable {
  @override
  List<Object> get props => [];
  ItemRepositoryState() : super();
}

class InitialRepositoryState extends ItemRepositoryState {}

class LoadingRepositoryState extends ItemRepositoryState {}

class FilteredItemCategories extends ItemRepositoryState {
  final Iterable<Category> filteredCategories;

  FilteredItemCategories({required this.filteredCategories});

  @override
  List<Object> get props => [filteredCategories];
}

class FilteredItems extends ItemRepositoryState {
  final Iterable<Item> filteredItems;

  FilteredItems({required this.filteredItems});

  @override
  List<Object> get props => [filteredItems];
}

class FilteredMarketGroups extends ItemRepositoryState {
  final Iterable<MarketGroup> filteredMarketGroups;

  FilteredMarketGroups({required this.filteredMarketGroups});

  @override
  List<Object> get props => [filteredMarketGroups];
}
