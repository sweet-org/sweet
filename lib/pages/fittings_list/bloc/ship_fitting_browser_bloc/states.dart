

import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ShipFittingBrowserState extends Equatable {
  @override
  List<Object> get props => [];
  ShipFittingBrowserState([List props = const []]) : super();
}

class ShipFittingBrowserLoading extends ShipFittingBrowserState {}

class ShipFittingBrowserLoaded extends ShipFittingBrowserState {
  final Iterable<ShipFittingLoadout> fittings;

  ShipFittingBrowserLoaded(this.fittings);

  @override
  List<Object> get props => [fittings];
}
