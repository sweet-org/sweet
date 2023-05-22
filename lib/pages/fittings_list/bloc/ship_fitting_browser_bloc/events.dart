

import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ShipFittingBrowserEvent extends Equatable {
  @override
  List<Object> get props => [];
  ShipFittingBrowserEvent([List props = const []]) : super();
}

class CreateShipFitting extends ShipFittingBrowserEvent {
  final String name;
  final Item ship;

  CreateShipFitting(this.name, this.ship);

  @override
  List<Object> get props => [
        name,
        ship,
      ];
}

class LoadAllShipFittings extends ShipFittingBrowserEvent {
  LoadAllShipFittings();

  @override
  List<Object> get props => [DateTime.now()];
}

class UpdateShipFitting extends ShipFittingBrowserEvent {
  final ShipFittingLoadout shipFitting;

  UpdateShipFitting({required this.shipFitting});

  @override
  List<Object> get props => [shipFitting];
}

class ImportShipFitting extends ShipFittingBrowserEvent {
  final ShipFittingLoadout shipFitting;

  ImportShipFitting({required this.shipFitting});

  @override
  List<Object> get props => [shipFitting];
}

class CloneShipFitting extends ShipFittingBrowserEvent {
  final ShipFittingLoadout shipFitting;
  final String fittingName;

  CloneShipFitting({
    required this.shipFitting,
    required this.fittingName,
  });

  @override
  List<Object> get props => [
        shipFitting,
        fittingName,
      ];
}

class DeleteShipFitting extends ShipFittingBrowserEvent {
  final String shipFittingId;

  DeleteShipFitting({required this.shipFittingId});

  @override
  List<Object> get props => [shipFittingId];
}

class ReorderShipFitting extends ShipFittingBrowserEvent {
  final ShipFittingLoadout shipFitting;
  final int newIndex;

  ReorderShipFitting({
    required this.shipFitting,
    required this.newIndex,
  });

  @override
  List<Object> get props => [
        shipFitting,
        newIndex,
      ];
}
