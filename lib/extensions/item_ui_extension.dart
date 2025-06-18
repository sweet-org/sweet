import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

extension ItemUI on Item {
  List<EveEchoesAttribute> get uiAttributes {
    if (marketGroupId == null) return [];

    switch (marketGroupId! ~/ 100000) {
      // parent groups
      // TODO: Replace magic numbers with concrete values
      case 1010: // High
        switch (marketGroupId! ~/ 100) {
          case 1010030: // Missiles
            return [
              EveEchoesAttribute.missileRange,
              EveEchoesAttribute.flightVelocity,
              EveEchoesAttribute.flightTime,
              EveEchoesAttribute.explosionRadius,
              EveEchoesAttribute.explosionVelocity,
            ];
          case 1010031: // Mining Things
            return [
              EveEchoesAttribute.miningAmount,
              EveEchoesAttribute.activationTime,
              EveEchoesAttribute.optimalRange,
            ];
          case 101019000: //Burst Projectors
            return [
              EveEchoesAttribute.optimalRange,
              EveEchoesAttribute.optimalEffectiveRange,
              EveEchoesAttribute.falloffRange,
              EveEchoesAttribute.duration,
              // Energy Neutralization
              EveEchoesAttribute.neutralizationAmount,
              EveEchoesAttribute.energyTransferAmount,
              // Fire Control Disruption
              EveEchoesAttribute.accuracyFalloffAdjustmentMod,
              EveEchoesAttribute.rangeSkillBonusMod,
              // Radar Disruption
              EveEchoesAttribute.trackingSpeedAdjustmentMod,
              EveEchoesAttribute.flightVelocityAdjustment,
              EveEchoesAttribute.scanResolutionAdjustment,
              EveEchoesAttribute.signatureRadiusAdjustment,
              EveEchoesAttribute.explosionVelocityBonusMod,
              EveEchoesAttribute.explosionRadiusBonusMod,
              EveEchoesAttribute.flightTimeBonusMod,
              // Power Disruption
              EveEchoesAttribute.capacitorCapacityMultiplierMod,
              EveEchoesAttribute.capacitorRechargeTimeMod,
              // Defense Disruption
              EveEchoesAttribute.shieldDamageTaken,
              EveEchoesAttribute.armorDamageTaken,
            ];
          case 101019010: // Doomsday weapons
              return [
                EveEchoesAttribute.warmupTime,
                EveEchoesAttribute.beamRadius,
                EveEchoesAttribute.attackInterval,
                EveEchoesAttribute.effectDuration,
                EveEchoesAttribute.targetLimit,
                EveEchoesAttribute.shieldBoostEffect,
                EveEchoesAttribute.armorRepairEffect,
                // ToDo: Implement additional effects like 'Turrets Damage'
              ];
        }

        return [
          EveEchoesAttribute.optimalRange,
          EveEchoesAttribute.accuracyFalloff,
          EveEchoesAttribute.trackingSpeed,
        ];
      case 1020: // Mids
        switch (marketGroupId! ~/ 100) {
          case 1020192: // Scanners
            return [
              EveEchoesAttribute.minScanRadius,
              EveEchoesAttribute.scanRadius,
              EveEchoesAttribute.activationTime,
              EveEchoesAttribute.fuelNeed,
            ];
        }

        return [
          EveEchoesAttribute.fighterNumberLimit,
          EveEchoesAttribute.optimalRange,
          EveEchoesAttribute.accuracyFalloff,
          EveEchoesAttribute.trackingSpeed,
          EveEchoesAttribute.minScanRadius,
          EveEchoesAttribute.scanRadius,
          EveEchoesAttribute.activationTime,
          EveEchoesAttribute.activationCost,
          EveEchoesAttribute.powerGridRequirement,
          EveEchoesAttribute.fuelNeed,
          EveEchoesAttribute.warpDisruptDistance
        ];

      case 1040: // Combat Rigs
      case 1050: // Engineer Rigs
        return [];

      case 1030040:
      default:
        return [
          EveEchoesAttribute.armorRepair,
          EveEchoesAttribute.shieldBoostAmount,
          EveEchoesAttribute.powerGridRequirement,
          EveEchoesAttribute.activationTime,
          EveEchoesAttribute.activationCost,
        ];
    }
  }
}
