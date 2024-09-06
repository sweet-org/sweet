import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sweet/database/entities/entities.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';
import 'package:sweet/widgets/localised_text.dart';

import '../module_state_toggle.dart';

typedef ImplantModuleToggle = void Function(int slotId, ModuleState state);

class FittingImplantTileDetails extends StatelessWidget {
  const FittingImplantTileDetails({
    Key? key,
    required this.fitting,
    required this.implant,
    required this.onStateToggle,
  }) : super(key: key);

  final ImplantFitting implant;
  final FittingSimulator fitting;
  final ImplantModuleToggle onStateToggle;

  @override
  Widget build(BuildContext context) {
    final attributes = [
      MapEntry(implant, implant.primarySkillAttributes),
      ...implant.allModules
          .where((e) => e.isValid)
          .sorted((a, b) => a.level - b.level)
          .map((e) => MapEntry(e, e.baseAttributes))
    ];

    return Column(
      children: [
        Column(
          children: [
            Text(
              "Warning: Main effects not supported, "
                  "they won't be included in calculations.",
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error),
            ),
            Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ModuleStateToggle(
                  onToggle: (state) => onStateToggle(0, state),
                  state: implant.primarySkillState,
                ),
              ),
              LocalisedText(
                item: implant.item,
              ),
            ]),
            ...implant.allModules
                .where((mod) => mod.isValid && mod.canActivate)
                .map((e) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ModuleStateToggle(
                      onToggle: (state) => onStateToggle(e.level, state),
                      state: e.state,
                    ),
                  ),
                  LocalisedText(
                    item: e.item,
                  )
                ],
              );
            }),
          ].toList(),
        ),
        Column(
          children: List<Widget>.of(
            attributes
                .map(((e) => buildAttrSection(e.key as FittingItem, e.value))),
          ),
        ),
      ],
    );
  }

  Widget buildAttrSection(FittingItem item, List<Attribute> attrs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              LocalisedText(
                item: item.item,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ...attrs
              .where((attr) => (attr.nameLocalisationKey ?? 0) > 0)
              .where((attr) => !kIgnoreImplantAttributes.contains(attr.id))
              .map((e) {
            var value = fitting.getValueForItemWithAttributeId(
              attributeId: e.id,
              item: item,
            );
            return value != 0
                ? ItemAttributeValueWidget(
                    attributeId: e.id,
                    attributeValue: value,
                    fixedDecimals: 2,
                    showAttributeId: true,
                  )
                : Container();
          })
        ],
      ),
    );
  }
}
