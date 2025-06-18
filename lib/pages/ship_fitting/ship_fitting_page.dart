

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_body.dart';
import 'package:flutter/material.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';

import 'widgets/ship_fitting_header.dart';

class ShipFittingPage extends StatelessWidget {
  static const routeName = '/fitting';
  final FittingSimulator fitting;

  const ShipFittingPage({super.key, required this.fitting});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShipFittingBloc>(
        create: (context) => ShipFittingBloc(
              RepositoryProvider.of<ItemRepository>(context),
              RepositoryProvider.of<ShipFittingLoadoutRepository>(context),
              RepositoryProvider.of<ImplantFittingLoadoutRepository>(context),
              fitting,
            ),
        child: ChangeNotifierProvider.value(
          value: fitting,
          child: Scaffold(
            body: Container(
              child: Column(
                verticalDirection: VerticalDirection.up,
                children: [
                  Expanded(
                    child: ShipFittingBody(),
                  ),
                  ShipFittingHeader(),
                ],
              ),
            ),
          ),
        ));
  }
}
