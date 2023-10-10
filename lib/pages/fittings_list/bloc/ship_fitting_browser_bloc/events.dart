

import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/ship/fitting_list_element.dart';
import 'package:sweet/model/ship/ship_fitting_folder.dart';
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

class CreateFittingFolder extends ShipFittingBrowserEvent {

  CreateFittingFolder();

  @override
  List<Object> get props => [];
}

class MoveFittingToFolder extends ShipFittingBrowserEvent {
  final String folderId;
  final FittingListElement fitting;

  MoveFittingToFolder(this.fitting, this.folderId);

  @override
  List<Object> get props => [
    fitting,
    folderId,
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
  final FittingListElement element;
  final int newIndex;

  ReorderShipFitting({
    required this.element,
    required this.newIndex,
  });

  @override
  List<Object> get props => [
    element,
        newIndex,
      ];
}

class RenameFittingFolder extends ShipFittingBrowserEvent {
  final ShipFittingFolder folder;
  final String newName;

  RenameFittingFolder({
    required this.folder,
    required this.newName,
  });

  @override
  List<Object> get props => [
    folder,
    newName,
  ];
}
