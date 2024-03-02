import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/pages/ship_fitting/widgets/module_tiles/fitting_module_tile.dart';
import 'package:sweet/pages/ship_fitting/widgets/module_tiles/fitting_module_tile_details.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:tinycolor2/tinycolor2.dart';

class FittingRigIntegratorTileDetails extends StatelessWidget {
  const FittingRigIntegratorTileDetails({
    Key? key,
    required this.fitting,
    required this.integrator,
  }) : super(key: key);

  final FittingRigIntegrator integrator;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FittingModuleTileDetails(
            fitting: fitting,
            module: integrator,
          ),
        ),
        ExpansionTile(
          backgroundColor: Theme.of(context).cardColor.darken(),
          collapsedBackgroundColor: Theme.of(context).cardColor.darken(),
          title: Text('Rigs'),
          children: List.generate(
            integrator.numberOfSlots,
            (index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittingModuleTile(
                  index: index,
                  module: integrator.rigAtIndex(index),
                  onTap: (index) => context.read<ShipFittingBloc>().add(
                        ShowRigIntegrationMenu(
                          rigIntegrator: integrator,
                          parentMarketGroupId: integrator.rootMarketGroupId,
                          slotIndex: index,
                        ),
                      ),
                  onClearPressed: () {
                    integrator.fit(
                      rig: FittingModule.empty,
                      index: index,
                    );

                    final fitting =
                        Provider.of<FittingSimulator>(context, listen: false);

                    // Refit item to trigger the required paths
                    fitting.fitItem(
                      integrator,
                      slot: integrator.slot,
                      index: integrator.index,
                    );
                  },
                  onClonePressed: (int index) {
                    // We don't want to allow cloning of items, as only one rig
                    // of a kind is allowed in a integrated rig
                  },
                  onStateToggle: (_) {},
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
