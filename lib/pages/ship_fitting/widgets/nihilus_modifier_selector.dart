import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/nihilus_space_modifier.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:tinycolor2/tinycolor2.dart';

class NihilusModifierSelector extends StatefulWidget {
  const NihilusModifierSelector({
    super.key,
  });

  @override
  State<NihilusModifierSelector> createState() =>
      _NihilusModifierSelectorState();
}

class _NihilusModifierSelectorState extends State<NihilusModifierSelector> {
  NihilusSpaceModifier? selectedMods;

  @override
  Widget build(BuildContext context) {
    final nSpaceMods = [
      null,
      ...RepositoryProvider.of<ItemRepository>(context).nSpaceMods,
    ];

    final fitting = RepositoryProvider.of<FittingSimulator>(context);

    return ExpansionTile(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      childrenPadding: EdgeInsets.symmetric(horizontal: 8),
      title: LocalisedText(
        localiseId: LocalisationStrings.nihilusEnvironment,
      ),
      subtitle: _buildSubtitle(),
      children: [
        Row(
          children: [
            Expanded(
              child: LocalisedText(
                localiseId: LocalisationStrings.capacitorRechargeTimeAdjustment,
              ),
            ),
            DropdownButton<NihilusSpaceModifier?>(
              value: selectedMods,
              onChanged: (e) => {
                setState(() {
                  selectedMods = e;
                  fitting.updateNihilusModifiers(e != null ? [e] : []);
                })
              },
              items: nSpaceMods
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e == null ? 'None' : '${e.uiValue.toStringAsFixed(0)}%',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        )
      ],
    );
  }

  Widget? _buildSubtitle() {
    final mod = selectedMods;

    if (mod == null) return null;

    return Row(
      children: [
        Text(
          '${mod.uiValue.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        LocalisedText(
          localiseId: LocalisationStrings.capacitorRechargeTimeAdjustment,
          style: Theme.of(context).textTheme.bodySmall,
        )
      ],
    );
  }
}
