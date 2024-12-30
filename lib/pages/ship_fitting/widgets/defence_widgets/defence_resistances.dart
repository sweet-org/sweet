import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

import 'resistance_row.dart';
import 'resistance_row_header.dart';

typedef EhpToggleCallback = void Function(bool showEHP);

class DefenceResistances extends StatefulWidget {
  final double rowHeight;
  final FittingPattern damagePattern;
  final EhpToggleCallback onEhpToggle;
  final double rowMargin;

  const DefenceResistances({
    Key? key,
    required this.rowHeight,
    required this.damagePattern,
    required this.onEhpToggle,
    this.rowMargin = 2,
  }) : super(key: key);

  @override
  State<DefenceResistances> createState() => _DefenceResistancesState();
}

class _DefenceResistancesState extends State<DefenceResistances> {
  bool _showEHP = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResistanceRowHeader(
          showEHP: _showEHP,
          rowHeight: widget.rowHeight,
          onEHPToggle: () {
            setState(() {
              _showEHP = !_showEHP;
              widget.onEhpToggle(_showEHP);
            });
          },
        ),
        for (var kvp in kDefenceAttributes.entries)
          ResistanceRow(
            showEHP: _showEHP,
            rowHeight: widget.rowHeight,
            rowAttribute: kvp.key,
            resistanceAttributes: kvp.value,
            damagePattern: widget.damagePattern,
            margin: widget.rowMargin,
          ),
      ],
    );
  }
}
