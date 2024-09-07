import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ShipFittingEvent extends Equatable {}

class ChangePilotForFitting extends ShipFittingEvent {
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class ChangeDamagePatternForFitting extends ShipFittingEvent {
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class SaveShipFitting extends ShipFittingEvent {
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class ShowShipFittingStats extends ShipFittingEvent {
  @override
  List<Object> get props => [
        DateTime.now(),
      ];
}

class ShowFittingsMenu extends ShipFittingEvent {
  final SlotType slotType;
  final int? slotIndex;

  ShowFittingsMenu({
    required this.slotType,
    this.slotIndex,
  });

  @override
  List<Object?> get props => [
        slotType,
        slotIndex,
        DateTime.now(),
      ];
}

class ShowNanocoreAffixMenu extends ShipFittingEvent {
  final int slotIndex;

  ShowNanocoreAffixMenu({required this.slotIndex});

  @override
  List<Object?> get props => [
    slotIndex,
    DateTime.now(),
  ];
}

class ShowRigIntegrationMenu extends ShipFittingEvent {
  final FittingRigIntegrator rigIntegrator;
  final int parentMarketGroupId;
  final int? integrationGroupId;
  final int slotIndex;

  ShowRigIntegrationMenu({
    required this.rigIntegrator,
    required this.parentMarketGroupId,
    this.integrationGroupId,
    required this.slotIndex,
  });

  @override
  List<Object?> get props => [
        slotIndex,
        parentMarketGroupId,
        integrationGroupId,
        DateTime.now(),
      ];
}
