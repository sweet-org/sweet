// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum RootPages {
  MarketBrowser,
  ItemBrowser,
  CharacterBrowser,
  FittingTool,
  PatchNotes
}

@immutable
abstract class NavigationState extends Equatable {
  String get title;

  @override
  List<Object> get props => [];
  NavigationState() : super();
}

class PushNavigationRoute extends NavigationState {
  final String route;

  @override
  List<Object> get props => [route];
  PushNavigationRoute(this.route) : super();

  @override
  String get title => '';
}

class ResetRootState extends NavigationState {
  final RootPages defaultPage;

  @override
  List<Object> get props => [defaultPage];

  @override
  String get title {
    switch (defaultPage) {
      case RootPages.ItemBrowser:
        return 'Item Browser';

      case RootPages.MarketBrowser:
        return 'Market Browser';

      case RootPages.CharacterBrowser:
        return 'Character Browser';

      case RootPages.FittingTool:
        return 'Ship Fittings';

      case RootPages.PatchNotes:
        return 'Announcements';
    }
  }

  ResetRootState(this.defaultPage);
}
