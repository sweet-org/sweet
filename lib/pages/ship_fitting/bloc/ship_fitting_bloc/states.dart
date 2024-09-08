import 'package:sweet/database/database_exports.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ShipFittingState extends Equatable {
  final FittingSimulator fitting;

  ShipFittingState(this.fitting);
}

class InitialShipFitting extends ShipFittingState {
  InitialShipFitting(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}

class UpdatingShipFitting extends ShipFittingState {
  UpdatingShipFitting(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}

class OpenContextDrawerState extends ShipFittingState {
  final MarketGroup topGroup;
  final List<Item> initialItems;
  final int? slotIndex;
  final SlotType slotType;

  OpenContextDrawerState(
    this.topGroup,
    this.initialItems,
    this.slotType,
    this.slotIndex,
    FittingSimulator fitting,
  ) : super(fitting);

  @override
  List<Object> get props => [
        // topGroup,
        // slotIndex,
        // slotType,
        // fitting,
        DateTime.now(),
      ];
}

class OpenRigIntegratorDrawer extends ShipFittingState {
  final FittingRigIntegrator rigIntegrator;
  final MarketGroup topGroup;
  final List<Item> initialItems;
  final int slotIndex;
  final List<int> blacklistItems;

  OpenRigIntegratorDrawer({
    required this.rigIntegrator,
    required this.topGroup,
    required this.initialItems,
    required this.slotIndex,
    required FittingSimulator fitting,
    this.blacklistItems = const []
  }) : super(fitting);

  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class OpenImplantDrawer extends ShipFittingState {
  OpenImplantDrawer(FittingSimulator fitting) : super(fitting);

  @override
  List<Object?> get props => [
        DateTime.now(),
      ];
}

class OpenNanocoreAffixDrawer extends ShipFittingState {
  final List<GoldNanoAttrClass> topClasses;
  final List<ItemNanocoreAffix> initialItems;
  final int slotIndex;
  final bool active;

  OpenNanocoreAffixDrawer({
    required this.topClasses,
    required this.initialItems,
    required this.slotIndex,
    required this.active,
    required FittingSimulator fitting,
  }) : super(fitting);

  @override
  List<Object> get props => [
    DateTime.now(),
  ];
}

class ShipFittingUpdatedState extends ShipFittingState {
  ShipFittingUpdatedState(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}

class OpenPilotDrawerState extends ShipFittingState {
  OpenPilotDrawerState(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}

class OpenDamagePatternDrawerState extends ShipFittingState {
  OpenDamagePatternDrawerState(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}

class OpenFittingStatsDrawerState extends ShipFittingState {
  OpenFittingStatsDrawerState(FittingSimulator fitting) : super(fitting);

  @override
  List<Object> get props => [
        // fitting,
        DateTime.now(),
      ];
}
