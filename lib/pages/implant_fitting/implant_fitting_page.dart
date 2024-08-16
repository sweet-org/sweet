

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/pages/implant_fitting/widgets/implant_fitting_body.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_body.dart';
import 'package:flutter/material.dart';
import 'package:sweet/repository/item_repository.dart';

import '../../repository/implant_fitting_loadout_repository.dart';
import 'bloc/implant_fitting_bloc/bloc.dart';
import 'widgets/implant_fitting_header.dart';

//import 'widgets/ship_fitting_header.dart';

class ImplantFittingPage extends StatelessWidget {
  static const routeName = '/implant';
  final ImplantHandler implant;

  const ImplantFittingPage({Key? key, required this.implant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImplantFittingBloc>(
        create: (context) => ImplantFittingBloc(
              RepositoryProvider.of<ItemRepository>(context),
              RepositoryProvider.of<ImplantFittingLoadoutRepository>(context),
              implant,
            ),
        child: ChangeNotifierProvider.value(
          value: implant,
          child: Scaffold(
            body: Container(
              child: Column(
                verticalDirection: VerticalDirection.up,
                children: [
                  Expanded(
                    child: ImplantFittingBody(),
                  ),
                  ImplantFittingHeader(),
                ],
              ),
            ),
          ),
        )
    );
  }
}
