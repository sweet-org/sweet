import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class NavigationEvent extends Equatable {
  @override
  List<Object> get props => [];
  NavigationEvent([List props = const []]) : super();
}

class RequestNavigationRoute extends NavigationEvent {
  final String route;
  @override
  List<Object> get props => [route];

  RequestNavigationRoute(this.route) : super();
}

class ShowMarketBrowserPage extends NavigationEvent {}

class ShowItemBrowserPage extends NavigationEvent {}

class ShowCharacterBrowserPage extends NavigationEvent {}

class ShowFittingToolPage extends NavigationEvent {}

class ShowImplantToolPage extends NavigationEvent {}

class ShowPatchNotesPage extends NavigationEvent {}

class ShowSettingsPage extends NavigationEvent {}
