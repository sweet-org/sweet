import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_nanocore.dart';
import 'package:sweet/model/fitting/fitting_nanocore_attribute_list.dart';
import 'package:sweet/pages/ship_fitting/nanocore_attribute_bonus.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:sweet/extensions/item_modifier_ui_extension.dart';

class FittingNanocoreTileDetails extends StatelessWidget {
  const FittingNanocoreTileDetails({
    Key? key,
    required this.fitting,
    required this.module,
  }) : super(key: key);

  final FittingModule module;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    final nanocore = module as FittingNanocore;

    return Column(
      children: [
        NanocoreAttributeListTile(
          title: LocalisedText(
            localiseId: LocalisationStrings.mainAttribute,
          ),
          nanocoreAttribute: nanocore.mainAttribute,
          fitting: fitting,
        ),
        ...nanocore.trainableAttributes.map(
          (nanocoreAttribute) => NanocoreAttributeListTile(
            title: LocalisedText(
              localiseId: LocalisationStrings.trainable,
            ),
            nanocoreAttribute: nanocoreAttribute,
            fitting: fitting,
          ),
        ),
      ],
    );
  }
}

class NanocoreAttributeListTile extends StatelessWidget {
  const NanocoreAttributeListTile({
    Key? key,
    required this.title,
    required this.nanocoreAttribute,
    required this.fitting,
  }) : super(key: key);

  final Widget title;
  final FittingNanocoreAttributeList nanocoreAttribute;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final loadoutRepo = RepositoryProvider.of<ShipFittingLoadoutRepository>(
      context,
    );
    final itemRepo = RepositoryProvider.of<ItemRepository>(
      context,
    );
    final localisation = RepositoryProvider.of<LocalisationRepository>(
      context,
    );

    final selectedName = nanocoreAttribute.selectedModifier?.modifierName(
          localisation: localisation,
          itemRepository: itemRepo,
        ) ??
        Future.value('');

    return FutureBuilder<String>(
      future: selectedName,
      initialData: '',
      builder: (context, snapshot) {
        final subtitle = snapshot.data ?? '';
        return ExpansionTile(
          backgroundColor: Theme.of(context).cardColor.darken(2),
          collapsedBackgroundColor: Theme.of(context).cardColor.darken(2),
          childrenPadding: EdgeInsets.only(bottom: 8),
          title: title,
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          children: [
            NanocoreAttributeSelector(
              attribute: nanocoreAttribute,
              color: color,
              onTap: (modifier, level) async {
                if (nanocoreAttribute.selectedAttribute == modifier &&
                    modifier?.selectedLevel == level) {
                  nanocoreAttribute.selectAttribute(null);
                } else {
                  nanocoreAttribute.selectAttribute(
                    level == null ? null : modifier,
                    level: level,
                  );
                }

                fitting.updateLoadout();

                await loadoutRepo.saveLoadouts();
              },
            ),
          ],
        );
      },
    );
  }
}

class NanocoreAttributeSelector extends StatelessWidget {
  const NanocoreAttributeSelector({
    Key? key,
    required this.attribute,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final FittingNanocoreAttributeList attribute;

  final Color color;

  final SelectedModifierCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: attribute.attributes.map(
        (e) {
          return Container(
            width: 185,
            height: 90,
            child: Card(
              color: color.withAlpha(
                attribute.selectedAttribute == e ? 255 : 0,
              ),
              child: InkWell(
                onTap: () => onTap(
                  e,
                  e.hasRange ? null : e.levels.first,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: NanocoreAttributeBonus(
                    nanocoreAttribute: e,
                    onTap: onTap,
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
