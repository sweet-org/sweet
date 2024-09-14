import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/fitting/fitting.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_nanocore.dart';
import 'package:sweet/model/fitting/fitting_nanocore_attribute_list.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/pages/ship_fitting/nanocore_attribute_bonus.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:sweet/extensions/item_modifier_ui_extension.dart';

import '../../../../model/fitting/fitting_nanocore_attribute.dart';
import '../../../../widgets/item_attribute_value_widget.dart';
import '../../bloc/ship_fitting_bloc/bloc.dart';
import '../../bloc/ship_fitting_bloc/events.dart';
import '../../nanocore_affix_bonus.dart';

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
        // ToDo: Combine both main attributes into one widget
        NanocoreAttributeListTile(
          title: LocalisedText(
            localiseId: LocalisationStrings.mainAttribute,
          ),
          nanocoreAttribute: nanocore.mainAttribute,
          fitting: fitting,
          validator: (m) => mainAttributeValidator(m, false),
        ),
        nanocore.isGolden
            ? NanocoreAttributeListTile(
                title: Text("Second Main Attribute"),
                nanocoreAttribute: nanocore.secondMainAttribute!,
                fitting: fitting,
                validator: (m) => mainAttributeValidator(m, true),
              )
            : Container(),
        nanocore.isGolden
            ? NanocoreAffixListTile(
                nanocore: nanocore,
                fitting: fitting,
                active: true,
                title: "Extended Attributes",
              )
            : Container(),
        nanocore.isGolden
            ? NanocoreAffixListTile(
                nanocore: nanocore,
                fitting: fitting,
                active: false,
                title: "Passive Nanocore Library",
                description: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Warning: Temporary solution, will be removed in the future.",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              )
            : Container(),
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

  bool mainAttributeValidator(
      FittingNanocoreAttribute? modifier, bool isSecond) {
    if (modifier == null) return true;
    final nanocore = module as FittingNanocore;
    final FittingNanocoreAttribute? otherAttr;
    if (isSecond) {
      otherAttr = nanocore.mainAttribute.selectedAttribute;
    } else {
      otherAttr = nanocore.secondMainAttribute?.selectedAttribute;
    }
    return otherAttr?.itemId != modifier.itemId;
  }
}

typedef SelectedAttributeValidator = bool Function(
  FittingNanocoreAttribute? modifier,
);

class NanocoreAttributeListTile extends StatelessWidget {
  const NanocoreAttributeListTile({
    Key? key,
    required this.title,
    required this.nanocoreAttribute,
    required this.fitting,
    this.validator,
  }) : super(key: key);

  final Widget title;
  final FittingNanocoreAttributeList nanocoreAttribute;
  final FittingSimulator fitting;
  final SelectedAttributeValidator? validator;

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
              validator: validator,
              onTap: (modifier, level) async {
                if (nanocoreAttribute.selectedAttribute == modifier &&
                    modifier?.selectedLevel == level) {
                  nanocoreAttribute.selectAttribute(null);
                } else {
                  if (level != null &&
                      validator != null &&
                      !validator!(modifier)) {
                    return;
                  }
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
    this.validator,
  }) : super(key: key);

  final FittingNanocoreAttributeList attribute;

  final Color color;

  final SelectedModifierCallback onTap;
  final SelectedAttributeValidator? validator;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: attribute.attributes.map(
        (e) {
          final Color attrColor;
          if (validator != null && !validator!(e)) {
            attrColor = Theme.of(context).disabledColor.darken(50);
          } else {
            attrColor = color.withAlpha(
              attribute.selectedAttribute == e ? 255 : 0,
            );
          }
          return Container(
            width: 185,
            height: 90,
            child: Card(
              color: attrColor,
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

class NanocoreAffixListTile extends StatelessWidget {
  const NanocoreAffixListTile({
    Key? key,
    required this.nanocore,
    required this.fitting,
    required this.active,
    this.title = "Nanocore Library",
    this.description,
  }) : super(key: key);

  final FittingNanocore nanocore;
  final FittingSimulator fitting;
  final bool active;
  final String title;
  final Widget? description;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final loadoutRepo = RepositoryProvider.of<ShipFittingLoadoutRepository>(
      context,
    );
    final localisation = RepositoryProvider.of<LocalisationRepository>(
      context,
    );

    final slots = <Widget>[];

    for (var i = 0; i < nanocore.getAffixes(active).length; i++) {
      slots.add(Container(
        width: 185,
        height: 100,
        child: Card(
          color: color.withAlpha(
            0,
          ),
          child: InkWell(
            onTap: () => {
              context
                  .read<ShipFittingBloc>()
                  .add(ShowNanocoreAffixMenu(slotIndex: i, active: active))
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: NanocoreAffixTile(
                index: i,
                affix: nanocore.getAffixes(active)[i],
                onSelectLevel: (int level) async {
                  final FittingNanocore nanocore = fitting
                      .modules(slotType: SlotType.nanocore)
                      .first as FittingNanocore;
                  nanocore.getAffixes(active)[i]!.selectLevel(level);
                  fitting.updateLoadout();
                  await loadoutRepo.saveLoadouts();
                },
              ),
            ),
          ),
        ),
      ));
    }

    final selCount = nanocore.getAffixes(active).whereNotNull().length;
    final String maxCount;
    if (active) {
      maxCount = "/${nanocore.getAffixes(active).length}";
    } else {
      maxCount = " (passive)";
    }

    return ExpansionTile(
      backgroundColor: Theme.of(context).cardColor.darken(2),
      collapsedBackgroundColor: Theme.of(context).cardColor.darken(2),
      childrenPadding: EdgeInsets.only(bottom: 8),
      title: Text(title),
      subtitle: Text(
        "$selCount$maxCount selected",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Column(
            children: [
              description ?? Container(),
              ...nanocore
                  .getAffixes(active)
                  .where((affix) =>
                      affix != null &&
                      (affix.baseAttributes[0].nameLocalisationKey ?? 0) > 0)
                  .map((e) {
                var attr = e!.baseAttributes[0];
                var value = fitting.getValueForItemWithAttributeId(
                  attributeId: attr.id,
                  item: e.selected,
                );
                var attrName = localisation.getLocalisedNameForAttribute(attr);
                var changeName = localisation.getLocalisedStringForIndex(
                    e.modifiers[0].changeRangeModuleNameId);
                var passiveMod = e.passiveModifiers[0];
                return value != 0
                    ? [
                        active
                            ? ItemAttributeValueWidget(
                                titleOverride: "$changeName $attrName",
                                attributeId: attr.id,
                                attributeValue: value,
                                fixedDecimals: 2,
                                showAttributeId: true,
                                truncate: true,
                              )
                            : Container(),
                        ItemAttributeValueWidget(
                          titleOverride: "$changeName $attrName (Passive)",
                          attributeId: passiveMod.attributeId,
                          attributeValue: passiveMod.attributeValue,
                          fixedDecimals: 2,
                          showAttributeId: true,
                          truncate: true,
                        ),
                      ]
                    : <Widget>[];
              }).expand((e) => e),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: slots,
        ),
      ],
    );
  }
}
