import 'package:flutter/material.dart';

List<EveEchoesAttribute> kDamageAttributes = [
  EveEchoesAttribute.emDamage,
  EveEchoesAttribute.thermalDamage,
  EveEchoesAttribute.kineticDamage,
  EveEchoesAttribute.explosiveDamage,
];

var kDefenceAttributes = {
  // Sheild
  EveEchoesAttribute.shieldCapacity: [
    EveEchoesAttribute.shieldEmDamageResonance,
    EveEchoesAttribute.shieldThermalDamageResonance,
    EveEchoesAttribute.shieldKineticDamageResonance,
    EveEchoesAttribute.shieldExplosiveDamageResonance,
  ],
  // Armor
  EveEchoesAttribute.armorHp: [
    EveEchoesAttribute.armorEmDamageResonance,
    EveEchoesAttribute.armorThermalDamageResonance,
    EveEchoesAttribute.armorKineticDamageResonance,
    EveEchoesAttribute.armorExplosiveDamageResonance,
  ],
  // Hull
  EveEchoesAttribute.hullHp: [
    EveEchoesAttribute.hullEmDamageResonance,
    EveEchoesAttribute.hullThermalDamageResonance,
    EveEchoesAttribute.hullKineticDamageResonance,
    EveEchoesAttribute.hullExplosiveDamageResonance,
  ],
};

/// Attributes that should always be cached for fitting
final kFittingAttributes = [
  EveEchoesAttribute.warpScrambleStatus,
  EveEchoesAttribute.moduleCanFitPolar,
  EveEchoesAttribute.moduleCanFitDefField,
  EveEchoesAttribute.moduleCanFitDefLink,
  EveEchoesAttribute.moduleCanFitCovert,
  EveEchoesAttribute.moduleCanFitWarpBubble,
  EveEchoesAttribute.moduleCanFitCommandLink,
  EveEchoesAttribute.moduleCanFitStripMiner,
  EveEchoesAttribute.moduleCanFitWarpDisruptionField,
];

final kSlotAttributes = [
  EveEchoesAttribute.highSlotCount,
  EveEchoesAttribute.midSlotCount,
  EveEchoesAttribute.lowSlotCount,
  EveEchoesAttribute.combatRigSlotCount,
  EveEchoesAttribute.engineeringRigSlotCount,
  EveEchoesAttribute.droneBayCount,
  EveEchoesAttribute.nanocoreSlotCount,
  EveEchoesAttribute.hangarRigSlots,
  EveEchoesAttribute.lightFFSlot,
  EveEchoesAttribute.lightDDSlot,
  // EveEchoesAttribute.lightCASlot,
  // EveEchoesAttribute.lightBCSlot,
  // EveEchoesAttribute.lightBBSlot,
  // EveEchoesAttribute.implantSlots,
];

final kIgnoreAttributes = [
  EveEchoesAttribute.metalevel,
  EveEchoesAttribute.techLevel,
  EveEchoesAttribute.moduleSize,
  EveEchoesAttribute.mass,
  EveEchoesAttribute.volume,
  EveEchoesAttribute.qualityBonus,
  EveEchoesAttribute.moduleSize,
  EveEchoesAttribute.maxGroupFitted,
  EveEchoesAttribute.maxGroupActive,
];

// There are way to many attributes when it comes to implants,
// this is the easy way...
final kIgnoreImplantAttributes = [
  EveEchoesAttribute.volume.attributeId,
  EveEchoesAttribute.cargoHoldCapacity.attributeId,
];

final kIgnoreAttributeIds = kIgnoreAttributes.map((e) => e.attributeId);

enum EveEchoesAttribute {
  // Module Slots
  highSlotCount,
  midSlotCount,
  lowSlotCount,
  combatRigSlotCount,
  engineeringRigSlotCount,
  droneBayCount,
  nanocoreSlotCount,
  hangarRigSlots,
  lightFFSlot,
  lightDDSlot,
  lightCASlot,
  lightBCSlot,
  lightBBSlot,
  implantSlots,

  // Shield
  shieldCapacity,
  shieldEmDamageResonance,
  shieldThermalDamageResonance,
  shieldKineticDamageResonance,
  shieldExplosiveDamageResonance,

  // Armor
  armorHp,
  armorEmDamageResonance,
  armorThermalDamageResonance,
  armorKineticDamageResonance,
  armorExplosiveDamageResonance,
  armorRepair,

  // Hull
  hullHp,
  hullEmDamageResonance,
  hullThermalDamageResonance,
  hullKineticDamageResonance,
  hullExplosiveDamageResonance,

  // Ship stats
  capacitorRechargeTime,
  capacitorCapacity,
  maxTargetRange,
  powerGridOutput,
  powerGridBonus,
  powerGridRequirement,
  signatureRadius,
  scanResolution,
  sensorStrength,
  warpSpeed,
  interiaModifier,
  flightVelocity,
  mass,
  speedBoost,
  speedBoostFactor,

  cargoHoldCapacity,
  mineralHoldCapacity,
  oreHoldCapacity,
  shipHoldCapacity,
  structureHoldCapacity,
  deliveryHoldCapacity,

  droneControlRange,
  droneBandwidth,
  droneCapacity,

  sourceRadius,
  scanRadius,
  minScanRadius,

  // Module
  activationTime,
  activationCost,
  moduleReactivationDelay,
  miningAmount,

  // Weapons
  optimalRange,
  accuracyFalloff,
  trackingSpeed,
  reloadTime,

  flightTime,
  explosionRadius,
  explosionVelocity,
  missileRange,

  // Doomsday Weapons
  warmupTime,
  beamRadius,
  attackInterval,
  effectDuration,
  targetLimit,
  shieldBoostEffect,
  armorRepairEffect,

  // Burst projectors
  optimalEffectiveRange,
  duration,
  falloffRange,
  signatureRadiusAdjustment,

  // Capacitor Warfare
  neutralizationAmount,
  energyTransferAmount,

  // Rig Bonuses
  damageBonus,
  activationTimeAdjustment,

  integrationEfficiency,
  integrationSlotNumber,
  integrationMaterialMultiplier,

  // Damage
  emDamage,
  thermalDamage,
  kineticDamage,
  explosiveDamage,
  damageMultiplier,

  // Misc
  fuelNeed,
  powerTransferAmount,
  warpScrambleStatus,
  entityEquipmentID,
  maxGroupActive,
  maxGroupOnline,
  maxTypeFitted,
  maxGroupFitted,
  maxLockedTargets,
  moduleSize,

  // Fitting constraints
  moduleCanFitAttributeID,
  moduleCanFitPolar,
  moduleCanFitDefField,
  moduleCanFitDefLink,
  moduleCanFitCovert,
  moduleCanFitWarpBubble,
  moduleCanFitCommandLink,
  moduleCanFitStripMiner,
  moduleCanFitWarpDisruptionField,

  // Effect modifiers
  accuracyFalloffAdjustmentMod,
  trackingSpeedAdjustmentMod,
  rangeSkillBonusMod,
  explosionVelocityBonusMod,
  explosionRadiusBonusMod,
  flightTimeBonusMod,
  capacitorCapacityMultiplierMod,
  capacitorRechargeTimeMod,
  shieldDamageTaken,
  armorDamageTaken,

  // Implant Attributes
  implantCBBuff,
  implantCBDamageModX,
  implantCBDamageDroneMod,

  // SORT!!
  metalevel,
  techLevel,
  qualityBonus,
  volume,
  inertiaModifierAdjustment,
  flightVelocityAdjustment,
  flightVelocityAdjustmentPenalty,
  warpSpeedIncrease,
  powerGridRequirementAdjustment,
  shieldBonus,
  shieldBoostAmount,
  shieldBoostAmountBonus,
  armorHitpointBonus,
  armorRepairBonus,
  structureHitpointBonus,
  capacitorCapacityMultiplier,
  capacitorRechargeTimeAdjustment,
  enableCapacitorNeedAdjustment,
  warpJammerstrength,
  warpDisruptDistance,
  scanResolutionAdjustment,
  rangeSkillBonus,
  accuracyFalloffAdjustment,
  explosionVelocityBonus,
  explosionRadiusBonus,
  flightTimeBonus,
  droneCommandRange,
  miningAmountBonus,
  cargoHoldCapacityBonus,
  minimumScanRadius,
  scanDetectRadius,
  signalSourceRadius,
  decipherType,
  decipherStrength,
  decipherStrengthMod,
  decipherRate,
  decipherRateMod1,
  decipherRateMod2,

  shieldEmDamageResonanceMultiplier,
  shieldThermalDamageResonanceMultiplier,
  shieldKineticDamageResonanceMultiplier,
  shieldExplosiveDamageResonanceMultiplier,
  shieldDamageResonanceDMod,
  shieldDamageResonanceMod,
  shieldDamageResonanceDModMod,
  shieldDamageResonanceDModShipMode,
  shieldRechargeRate,
  shieldRechargeRateMultiplier,
  armorHPMultiplier,
  armorHpBonus,
  armorDamage,
  armorDamageAmountMultiplier,
  armorDamageLimit,
  armorRepairLimit,
  armorUniformity,
  armorHpBonusMod,
  armorEmDamageResonanceMultiplier,
  armorThermalDamageResonanceMultiplier,
  armorKineticDamageResonanceMultiplier,
  armorExplosiveDamageResonanceMultiplier,
  armorDamageResonanceDMod,
  armorDamageResonanceMod,
  armorDamageResonanceDModMod,

  capacitorRechargeRateMultiplierN,
  isFleetOnly,

  fighterControlDistance,
  fighterNumberLimit,
}

extension ShipAttributeExtenstion on EveEchoesAttribute {
  String? get iconName {
    switch (this) {
      case EveEchoesAttribute.shieldCapacity:
        return 'assets/icons/icon-shield.png';

      case EveEchoesAttribute.armorHp:
        return 'assets/icons/icon-armor.png';

      case EveEchoesAttribute.hullHp:
        return 'assets/icons/icon-hull.png';

      case EveEchoesAttribute.shieldEmDamageResonance:
      case EveEchoesAttribute.armorEmDamageResonance:
      case EveEchoesAttribute.hullEmDamageResonance:
        return 'assets/icons/icon-resist-em.png';

      case EveEchoesAttribute.shieldThermalDamageResonance:
      case EveEchoesAttribute.armorThermalDamageResonance:
      case EveEchoesAttribute.hullThermalDamageResonance:
        return 'assets/icons/icon-resist-therm.png';

      case EveEchoesAttribute.shieldKineticDamageResonance:
      case EveEchoesAttribute.armorKineticDamageResonance:
      case EveEchoesAttribute.hullKineticDamageResonance:
        return 'assets/icons/icon-resist-kin.png';

      case EveEchoesAttribute.shieldExplosiveDamageResonance:
      case EveEchoesAttribute.armorExplosiveDamageResonance:
      case EveEchoesAttribute.hullExplosiveDamageResonance:
        return 'assets/icons/icon-resist-exp.png';

      case EveEchoesAttribute.emDamage:
        return 'assets/icons/icon-damage-em.png';
      case EveEchoesAttribute.thermalDamage:
        return 'assets/icons/icon-damage-therm.png';
      case EveEchoesAttribute.kineticDamage:
        return 'assets/icons/icon-damage-kin.png';
      case EveEchoesAttribute.explosiveDamage:
        return 'assets/icons/icon-damage-exp.png';

      default:
        return null;
    }
  }

  Color get color {
    switch (this) {
      case EveEchoesAttribute.emDamage:
      case EveEchoesAttribute.shieldEmDamageResonance:
      case EveEchoesAttribute.armorEmDamageResonance:
      case EveEchoesAttribute.hullEmDamageResonance:
        return Colors.blue;

      case EveEchoesAttribute.thermalDamage:
      case EveEchoesAttribute.shieldThermalDamageResonance:
      case EveEchoesAttribute.armorThermalDamageResonance:
      case EveEchoesAttribute.hullThermalDamageResonance:
        return Colors.red;

      case EveEchoesAttribute.kineticDamage:
      case EveEchoesAttribute.shieldKineticDamageResonance:
      case EveEchoesAttribute.armorKineticDamageResonance:
      case EveEchoesAttribute.hullKineticDamageResonance:
        return Colors.grey;

      case EveEchoesAttribute.explosiveDamage:
      case EveEchoesAttribute.shieldExplosiveDamageResonance:
      case EveEchoesAttribute.armorExplosiveDamageResonance:
      case EveEchoesAttribute.hullExplosiveDamageResonance:
        return Colors.orange;

      default:
        return Colors.pink;
    }
  }

  int get attributeId {
    switch (this) {
      case EveEchoesAttribute.highSlotCount:
        return 164;
      case EveEchoesAttribute.midSlotCount:
        return 166;
      case EveEchoesAttribute.lowSlotCount:
        return 168;
      case EveEchoesAttribute.combatRigSlotCount:
        return 170;
      case EveEchoesAttribute.engineeringRigSlotCount:
        return 172;
      case EveEchoesAttribute.droneBayCount:
        return 10104;
      case EveEchoesAttribute.nanocoreSlotCount:
        return 178;
      case EveEchoesAttribute.hangarRigSlots:
        return 10128;
      case EveEchoesAttribute.lightFFSlot:
        return 820;
      case EveEchoesAttribute.lightDDSlot:
        return 822;
      case EveEchoesAttribute.lightCASlot:
        return 824;
      case EveEchoesAttribute.lightBCSlot:
        return 826;
      case EveEchoesAttribute.lightBBSlot:
        return 828;
      case EveEchoesAttribute.implantSlots:
        return 750;

      case EveEchoesAttribute.hullHp:
        return 260;
      case EveEchoesAttribute.hullEmDamageResonance:
        return 271;
      case EveEchoesAttribute.hullThermalDamageResonance:
        return 272;
      case EveEchoesAttribute.hullKineticDamageResonance:
        return 273;
      case EveEchoesAttribute.hullExplosiveDamageResonance:
        return 274;

      case EveEchoesAttribute.capacitorRechargeTime:
        return 304;
      case EveEchoesAttribute.capacitorCapacity:
        return 300;

      case EveEchoesAttribute.maxTargetRange:
        return 350;
      case EveEchoesAttribute.powerGridOutput:
        return 180;
      case EveEchoesAttribute.powerGridBonus:
        return 181;
      case EveEchoesAttribute.powerGridRequirement:
        return 184;
      case EveEchoesAttribute.signatureRadius:
        return 360;
      case EveEchoesAttribute.scanResolution:
        return 352;
      case EveEchoesAttribute.sensorStrength:
        return 334;
      case EveEchoesAttribute.warpSpeed:
        return 150;
      case EveEchoesAttribute.interiaModifier:
        return 120;
      case EveEchoesAttribute.flightVelocity:
        return 130;
      case EveEchoesAttribute.mass:
        return 100;
      case EveEchoesAttribute.speedBoost:
        return 131;
      case EveEchoesAttribute.speedBoostFactor:
        return 103;

      case EveEchoesAttribute.cargoHoldCapacity:
        return 620;
      case EveEchoesAttribute.oreHoldCapacity:
        return 622;
      case EveEchoesAttribute.mineralHoldCapacity:
        return 623;
      case EveEchoesAttribute.structureHoldCapacity:
        return 624;
      case EveEchoesAttribute.shipHoldCapacity:
        return 10044;
      case EveEchoesAttribute.deliveryHoldCapacity:
        return 10103;

      case EveEchoesAttribute.droneControlRange:
        return 483;
      case EveEchoesAttribute.droneBandwidth:
        return 480;
      case EveEchoesAttribute.droneCapacity:
        return 481;

      case EveEchoesAttribute.miningAmount:
        return 580;

      case EveEchoesAttribute.activationTime:
        return 430;
      case EveEchoesAttribute.activationCost:
        return 310;
      case EveEchoesAttribute.moduleReactivationDelay:
        return 433;

      case EveEchoesAttribute.minScanRadius:
        return 700;
      case EveEchoesAttribute.scanRadius:
        return 704;
      case EveEchoesAttribute.sourceRadius:
        return 702;

      case EveEchoesAttribute.optimalRange:
        return 450;
      case EveEchoesAttribute.accuracyFalloff:
        return 453;
      case EveEchoesAttribute.trackingSpeed:
        return 456;
      case EveEchoesAttribute.reloadTime:
        return 490;

      case EveEchoesAttribute.flightTime:
        return 476;
      case EveEchoesAttribute.explosionRadius:
        return 473;
      case EveEchoesAttribute.explosionVelocity:
        return 470;
      case EveEchoesAttribute.missileRange:
        return -1; // Special Case Attribute

      case EveEchoesAttribute.damageBonus:
        return 411;
      case EveEchoesAttribute.activationTimeAdjustment:
        return 431;

      case EveEchoesAttribute.integrationEfficiency:
        return 190;
      case EveEchoesAttribute.integrationSlotNumber:
        return 191;
      case EveEchoesAttribute.integrationMaterialMultiplier:
        return 192;

      case EveEchoesAttribute.damageMultiplier:
        return 410;

      case EveEchoesAttribute.emDamage:
        return 413;
      case EveEchoesAttribute.thermalDamage:
        return 414;
      case EveEchoesAttribute.kineticDamage:
        return 415;
      case EveEchoesAttribute.explosiveDamage:
        return 416;

      case EveEchoesAttribute.fuelNeed:
        return 650;
      case EveEchoesAttribute.powerTransferAmount:
        return 320;
      case EveEchoesAttribute.warpScrambleStatus:
        return 330;
      case EveEchoesAttribute.entityEquipmentID:
        return 48;
      case EveEchoesAttribute.maxGroupActive:
        return 174;
      case EveEchoesAttribute.maxGroupOnline:
        return 175;
      case EveEchoesAttribute.maxTypeFitted:
        return 176;
      case EveEchoesAttribute.maxGroupFitted:
        return 177;
      case EveEchoesAttribute.maxLockedTargets:
        return 354;
      case EveEchoesAttribute.moduleSize:
        return 13;
      case EveEchoesAttribute.warpDisruptDistance:
        return 10010;

      case EveEchoesAttribute.moduleCanFitAttributeID:
        return 3000;
      case EveEchoesAttribute.moduleCanFitPolar:
        return 3001;
      case EveEchoesAttribute.moduleCanFitDefField:
        return 3005;
      case EveEchoesAttribute.moduleCanFitDefLink:
        return 3007;
      case EveEchoesAttribute.moduleCanFitCovert:
        return 3009;
      case EveEchoesAttribute.moduleCanFitWarpBubble:
        return 3011;
      case EveEchoesAttribute.moduleCanFitCommandLink:
        return 3019;
      case EveEchoesAttribute.moduleCanFitStripMiner:
        return 3023;
      case EveEchoesAttribute.moduleCanFitWarpDisruptionField:
        return 3025;

      case EveEchoesAttribute.metalevel:
        return 4;
      case EveEchoesAttribute.techLevel:
        return 1;
      case EveEchoesAttribute.qualityBonus:
        return 101;
      case EveEchoesAttribute.volume:
        return 106;
      case EveEchoesAttribute.inertiaModifierAdjustment:
        return 121;
      case EveEchoesAttribute.flightVelocityAdjustment:
        return 132;
      case EveEchoesAttribute.flightVelocityAdjustmentPenalty:
        return 143;
      case EveEchoesAttribute.warpSpeedIncrease:
        return 151;
      case EveEchoesAttribute.powerGridRequirementAdjustment:
        return 185;
      case EveEchoesAttribute.shieldBonus:
        return 201;
      case EveEchoesAttribute.shieldBoostAmount:
        return 204;
      case EveEchoesAttribute.shieldBoostAmountBonus:
        return 205;
      case EveEchoesAttribute.armorHitpointBonus:
        return 231;
      case EveEchoesAttribute.armorRepairBonus:
        return 235;
      case EveEchoesAttribute.structureHitpointBonus:
        return 261;
      case EveEchoesAttribute.capacitorCapacityMultiplier:
        return 301;
      case EveEchoesAttribute.capacitorRechargeTimeAdjustment:
        return 305;
      case EveEchoesAttribute.enableCapacitorNeedAdjustment:
        return 311;
      case EveEchoesAttribute.warpJammerstrength:
        return 331;
      case EveEchoesAttribute.scanResolutionAdjustment:
        return 353;
      case EveEchoesAttribute.rangeSkillBonus:
        return 451;
      case EveEchoesAttribute.accuracyFalloffAdjustment:
        return 454;
      case EveEchoesAttribute.explosionVelocityBonus:
        return 471;
      case EveEchoesAttribute.explosionRadiusBonus:
        return 474;
      case EveEchoesAttribute.flightTimeBonus:
        return 477;
      case EveEchoesAttribute.droneCommandRange:
        return 484;
      case EveEchoesAttribute.miningAmountBonus:
        return 581;
      case EveEchoesAttribute.cargoHoldCapacityBonus:
        return 621;
      case EveEchoesAttribute.minimumScanRadius:
        return 2068;
      case EveEchoesAttribute.scanDetectRadius:
        return 2081;
      case EveEchoesAttribute.signalSourceRadius:
        return 2082;

      case EveEchoesAttribute.decipherType:
        return 708;
      case EveEchoesAttribute.decipherStrength:
        return 709;
      case EveEchoesAttribute.decipherStrengthMod:
        return 710;
      case EveEchoesAttribute.decipherRate:
        return 711;
      case EveEchoesAttribute.decipherRateMod1:
        return 712;
      case EveEchoesAttribute.decipherRateMod2:
        return 713;

      case EveEchoesAttribute.shieldCapacity:
        return 200;
      case EveEchoesAttribute.shieldEmDamageResonance:
        return 211;
      case EveEchoesAttribute.shieldThermalDamageResonance:
        return 212;
      case EveEchoesAttribute.shieldKineticDamageResonance:
        return 213;
      case EveEchoesAttribute.shieldExplosiveDamageResonance:
        return 214;
      case EveEchoesAttribute.shieldEmDamageResonanceMultiplier:
        return 215;
      case EveEchoesAttribute.shieldThermalDamageResonanceMultiplier:
        return 216;
      case EveEchoesAttribute.shieldKineticDamageResonanceMultiplier:
        return 217;
      case EveEchoesAttribute.shieldExplosiveDamageResonanceMultiplier:
        return 218;
      case EveEchoesAttribute.shieldDamageResonanceDMod:
        return 223;
      case EveEchoesAttribute.shieldDamageResonanceMod:
        return 224;
      case EveEchoesAttribute.shieldDamageResonanceDModMod:
        return 226;
      case EveEchoesAttribute.shieldDamageResonanceDModShipMode:
        return 227;
      case EveEchoesAttribute.shieldRechargeRate:
        return 228;
      case EveEchoesAttribute.shieldRechargeRateMultiplier:
        return 229;
      case EveEchoesAttribute.armorHp:
        return 230;
      case EveEchoesAttribute.armorHPMultiplier:
        return 231;
      case EveEchoesAttribute.armorHpBonus:
        return 232;
      case EveEchoesAttribute.armorDamage:
        return 233;
      case EveEchoesAttribute.armorRepair:
        return 234;
      case EveEchoesAttribute.armorDamageAmountMultiplier:
        return 235;
      case EveEchoesAttribute.armorDamageLimit:
        return 236;
      case EveEchoesAttribute.armorRepairLimit:
        return 237;
      case EveEchoesAttribute.armorUniformity:
        return 238;
      case EveEchoesAttribute.armorHpBonusMod:
        return 239;
      case EveEchoesAttribute.armorEmDamageResonance:
        return 241;
      case EveEchoesAttribute.armorThermalDamageResonance:
        return 242;
      case EveEchoesAttribute.armorKineticDamageResonance:
        return 243;
      case EveEchoesAttribute.armorExplosiveDamageResonance:
        return 244;
      case EveEchoesAttribute.armorEmDamageResonanceMultiplier:
        return 245;
      case EveEchoesAttribute.armorThermalDamageResonanceMultiplier:
        return 246;
      case EveEchoesAttribute.armorKineticDamageResonanceMultiplier:
        return 247;
      case EveEchoesAttribute.armorExplosiveDamageResonanceMultiplier:
        return 248;
      case EveEchoesAttribute.armorDamageResonanceDMod:
        return 253;
      case EveEchoesAttribute.armorDamageResonanceMod:
        return 254;
      case EveEchoesAttribute.armorDamageResonanceDModMod:
        return 256;

      case EveEchoesAttribute.capacitorRechargeRateMultiplierN:
        return 308;

      case EveEchoesAttribute.isFleetOnly:
        return 905;

      case EveEchoesAttribute.fighterControlDistance:
        return 531;
      case EveEchoesAttribute.fighterNumberLimit:
        return 489;

      case EveEchoesAttribute.warmupTime:
        return 855;
      case EveEchoesAttribute.beamRadius:
        return 90;
      case EveEchoesAttribute.effectDuration:
        return 466;
      case EveEchoesAttribute.targetLimit:
        return 661;
      case EveEchoesAttribute.attackInterval:
        return 93;
      case EveEchoesAttribute.shieldBoostEffect:
        return 10196;
      case EveEchoesAttribute.armorRepairEffect:
        return 10197;
      case EveEchoesAttribute.optimalEffectiveRange:
        return 460;
      case EveEchoesAttribute.duration:
        return 1516;
      case EveEchoesAttribute.neutralizationAmount:
        return 324;
      case EveEchoesAttribute.energyTransferAmount:
        return 320;
      case EveEchoesAttribute.falloffRange:
        return 463;

      case EveEchoesAttribute.accuracyFalloffAdjustmentMod:
        return 10015;
      case EveEchoesAttribute.rangeSkillBonusMod:
        return 10016;
      case EveEchoesAttribute.trackingSpeedAdjustmentMod:
        return 10017;
      case EveEchoesAttribute.explosionVelocityBonusMod:
        return 10120;
      case EveEchoesAttribute.explosionRadiusBonusMod:
        return 10121;
      case EveEchoesAttribute.flightTimeBonusMod:
        return 10122;

      case EveEchoesAttribute.signatureRadiusAdjustment:
        return 364;


      case EveEchoesAttribute.capacitorCapacityMultiplierMod:
        return 306;
      case EveEchoesAttribute.capacitorRechargeTimeMod:
        return 307;
      case EveEchoesAttribute.shieldDamageTaken:
        return 98010;
      case EveEchoesAttribute.armorDamageTaken:
        return 98020;

      case EveEchoesAttribute.implantCBBuff:
        return 8681;
      case EveEchoesAttribute.implantCBDamageModX:
        return 8683;
      case EveEchoesAttribute.implantCBDamageDroneMod:
        return 8682;
    }
  }
}
