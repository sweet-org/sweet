import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/fitting/fitting_nanocore_affix.dart';
import 'package:sweet/repository/localisation_repository.dart';

typedef TapAffixSelectLevel = void Function(int level);

class NanocoreAffixTile extends StatelessWidget {
  final int index;
  final FittingNanocoreAffix? affix;
  final TapAffixSelectLevel onSelectLevel;

  const NanocoreAffixTile(
      {Key? key, required this.index, required this.affix, required this.onSelectLevel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);
    final moduleName = affix != null ?
        localisation.getLocalisedNameForItem(affix!.item.item) : '';
    return affix == null
        ? Center(child: Text("Tap to select"))
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildLevelSelector(context),
              Expanded(child: Center(
                child: AutoSizeText(
                  moduleName
                ),
              ))
            ],
          );
  }

  Widget buildLevelSelector(
    BuildContext context
      ) {
    final affix = this.affix!;
    return DropdownButton<FittingNanocoreAffixItem>(
      isDense: true,
      iconSize: 16,
      // hint: Text(bonusAmountString),
      alignment: AlignmentDirectional.center,
      value: affix.selected,
      onChanged: (e) => onSelectLevel(e?.level ?? 0),
      selectedItemBuilder: (context) => affix.availableLevels
          .map(
            (e) => AutoSizeText(
              "Lvl $e",
              minFontSize: 14,
              maxFontSize: 20,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          )
          .toList(),
      items: affix.levels.values
          .sorted((a, b) => a.level - b.level)
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Lvl ${e.level}",
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
