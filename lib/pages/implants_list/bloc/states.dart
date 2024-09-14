import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ImplantFittingBrowserState extends Equatable {
  @override
  List<Object> get props => [];
  ImplantFittingBrowserState([List props = const []]) : super();
}

class ImplantFittingBrowserLoading extends ImplantFittingBrowserState {}

class ImplantFittingBrowserLoaded extends ImplantFittingBrowserState {
  final Iterable<ImplantFittingLoadout> fittings;

  ImplantFittingBrowserLoaded(this.fittings);

  @override
  List<Object> get props => [fittings];
}
