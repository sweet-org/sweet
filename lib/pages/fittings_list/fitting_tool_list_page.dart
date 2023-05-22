import 'package:sweet/pages/fittings_list/bloc/ship_fitting_browser_bloc/ship_fitting_browser_bloc.dart';
import 'package:sweet/pages/fittings_list/widgets/fitting_tool_list.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FittingsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShipFittingBrowserBloc>(
      create: (context) => ShipFittingBrowserBloc(
        fittingRepository:
            RepositoryProvider.of<ShipFittingLoadoutRepository>(context),
        itemRepository: RepositoryProvider.of<ItemRepository>(context),
      ),
      child: FittingToolList(),
    );
  }
}
