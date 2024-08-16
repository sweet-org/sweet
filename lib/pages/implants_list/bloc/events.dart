import 'package:sweet/database/entities/item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../../model/implant/implant_fitting_loadout.dart';

@immutable
abstract class ImplantFittingBrowserEvent extends Equatable {
  @override
  List<Object?> get props => [];

  ImplantFittingBrowserEvent([List props = const []]) : super();
}

class CreateImplantFitting extends ImplantFittingBrowserEvent {
  final String name;
  final Item implant;

  CreateImplantFitting(this.name, this.implant);

  @override
  List<Object> get props => [
    name,
    implant,
  ];
}

class LoadAllImplantFittings extends ImplantFittingBrowserEvent {
  LoadAllImplantFittings();

  @override
  List<Object> get props => [DateTime.now()];
}

class UpdateImplantFitting extends ImplantFittingBrowserEvent {
  final ImplantFittingLoadout implantFitting;

  UpdateImplantFitting({required this.implantFitting});

  @override
  List<Object> get props => [implantFitting];
}

class DeleteImplantFitting extends ImplantFittingBrowserEvent {
  final String implantFittingId;

  DeleteImplantFitting({required this.implantFittingId});

  @override
  List<Object> get props => [implantFittingId];
}

