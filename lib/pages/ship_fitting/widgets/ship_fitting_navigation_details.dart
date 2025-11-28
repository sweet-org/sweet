import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';

import 'align_time_widget.dart';
import 'max_velocity_text.dart';
import 'ship_attribute_value.dart';

class ShipFittingNavigationDetails extends StatelessWidget {
  final bool condensed;

  const ShipFittingNavigationDetails({
    super.key,
    this.condensed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              child: Column(
                children: [
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.sourceRadius,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.signatureRadius,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.scanResolution,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.sensorStrength,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.interiaModifier,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.maxLockedTargets,
                  ),
                  SizedBox(height: 16),
                  // ToDo: I dont know how to detect ships with jump drives
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.jumpDriveRange,
                    titleOverride: "Jump Range",
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.jumpDriveCapCost,
                    titleOverride: "Capacitor Need",
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.jumpDriveFuelCost,
                    titleOverride: "Fuel Cost",
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.mass,
                  ),
                  MaxVelocityText(),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.warpSpeed,
                  ),
                  ShipAttributeValue(
                    titleOverride:
                        RepositoryProvider.of<LocalisationRepository>(context)
                            .getLocalisedStringForIndex(
                      LocalisationStrings.warpStability,
                    ),
                    attribute: EveEchoesAttribute.warpScrambleStatus,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.cargoHoldCapacity,
                    hideIfZero: true,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.oreHoldCapacity,
                    hideIfZero: true,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.mineralHoldCapacity,
                    hideIfZero: true,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.deliveryHoldCapacity,
                    hideIfZero: true,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.shipHoldCapacity,
                    hideIfZero: true,
                  ),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.structureHoldCapacity,
                    hideIfZero: true,
                  ),
                  AlignTimeWidget(),
                  ShipAttributeValue(
                    attribute: EveEchoesAttribute.shieldRechargeRate,
                    titleOverride: "Shield Recharge Rate",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
