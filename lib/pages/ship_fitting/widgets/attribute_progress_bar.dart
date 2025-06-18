import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/database/entities/unit.dart';
import 'package:sweet/pages/ship_fitting/widgets/icon_progress_bar.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';

class AttributeProgressBar extends StatefulWidget {
  final EveEchoesAttribute attribute;
  final double attributeValue;

  final double Function(double)? formulaOverride;
  final String? unitOverride;

  final double height;
  final bool inverted;

  const AttributeProgressBar({
    super.key,
    required this.attribute,
    required this.attributeValue,
    this.height = 24,
    this.inverted = false,
    this.formulaOverride,
    this.unitOverride,
  });

  @override
  State<AttributeProgressBar> createState() => _AttributeProgressBarState();
}

class _AttributeProgressBarState extends State<AttributeProgressBar> {
  late ItemRepository _itemRepository;
  late LocalisationRepository _localisationRepository;

  Attribute? _attributeDefinition;
  Unit? _unit;

  @override
  void initState() {
    super.initState();

    fetchAttributeDetails();
  }

  Future<void> fetchAttributeDetails() async {
    _itemRepository = RepositoryProvider.of<ItemRepository>(context);
    _localisationRepository =
        RepositoryProvider.of<LocalisationRepository>(context);

    if (widget.formulaOverride == null || widget.unitOverride == null) {
      _attributeDefinition = await _itemRepository.attributeWithId(
          id: widget.attribute.attributeId);
      _unit = await _itemRepository.unitWithId(
          id: _attributeDefinition?.unitId ?? 0);

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var value = widget.attributeValue;
    var printedValue = value;
    String? unitString;
    final attribute = _attributeDefinition;

    if (widget.inverted) {
      value = 1.0 - value;
    }

    if (widget.formulaOverride != null && widget.unitOverride != null) {
      printedValue = widget.formulaOverride!(value);
      unitString = widget.unitOverride;
    } else {
      if (attribute == null) {
        return SizedBox.fromSize(
          size: Size.square(widget.height),
          child: CircularProgressIndicator(),
        );
      }

      var localisedUnit =
          _localisationRepository.getLocalisedUnitForAttribute(attribute);

      unitString = _unit?.displayName ?? localisedUnit;

      printedValue =
          _attributeDefinition?.calculatedValue(fromValue: value) ?? 0;
    }
    return Container(
      margin: EdgeInsets.all(2),
      child: IconProgressbar(
          value: value,
          color: widget.attribute.color,
          height: widget.height,
          label: '${printedValue.toStringAsFixed(2)} $unitString'),
    );
  }
}
