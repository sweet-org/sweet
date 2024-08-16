import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:sweet/model/implant/slot_type.dart';

@immutable
abstract class ImplantFittingEvent extends Equatable {}

class SaveImplantFitting extends ImplantFittingEvent {
  @override
  List<Object> get props => [
    DateTime.now(),
  ];
}


class ShowFittingsMenu extends ImplantFittingEvent {
  final ImplantSlotType slotType;
  final int slotIndex;
  final List<int>? allowedItemIds;

  ShowFittingsMenu({
    required this.slotType,
    required this.slotIndex,
    this.allowedItemIds,
  });

  @override
  List<Object?> get props => [
    slotType,
    slotIndex,
    DateTime.now(),
  ];
}