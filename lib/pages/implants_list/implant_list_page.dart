import 'package:sweet/pages/implants_list/widget/implant_list.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart';

class ImplantsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImplantFittingBrowserBloc>(
      create: (context) => ImplantFittingBrowserBloc(
        fittingRepository:
            RepositoryProvider.of<ImplantFittingLoadoutRepository>(context),
        itemRepository: RepositoryProvider.of<ItemRepository>(context),
      ),
      child: ImplantList(),
    );
  }
}
