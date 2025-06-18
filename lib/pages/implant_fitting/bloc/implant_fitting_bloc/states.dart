import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/market_group.dart';
import 'package:sweet/model/implant/implant_handler.dart';

@immutable
abstract class ImplantFittingState extends Equatable {
  final ImplantHandler implant;

  ImplantFittingState(this.implant);
}

class InitialImplantFitting extends ImplantFittingState {
  InitialImplantFitting(super.implant);

  @override
  List<Object> get props => [
    // fitting,
    DateTime.now(),
  ];
}

class UpdatingImplantFitting extends ImplantFittingState {
  UpdatingImplantFitting(super.implant);

  @override
  List<Object> get props => [
    // fitting,
    DateTime.now(),
  ];
}

class ImplantFittingUpdatedState extends ImplantFittingState {
  ImplantFittingUpdatedState(super.implant);

  @override
  List<Object> get props => [
    // fitting,
    DateTime.now(),
  ];
}

class OpenContextDrawerState extends ImplantFittingState {
  final MarketGroup topGroup;
  final List<Item> initialItems;
  final int slotIndex;

  OpenContextDrawerState(
      this.topGroup,
      this.initialItems,
      this.slotIndex,
      ImplantHandler fitting,
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