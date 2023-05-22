import 'package:collection/collection.dart';

import '../character/learned_skill.dart';
import '../../database/entities/item.dart';

extension SkillItems on Item {
  LearnedSkill? get requiredSkill => requiredSkills.firstOrNull;
  Iterable<LearnedSkill> get requiredSkills {
    if (preSkill == null || preSkill!.isEmpty) return [];

    return preSkill!.map((preSkillString) {
      final parts = preSkillString.split('|');

      final skillId = int.tryParse(parts[0]) ?? 0;
      final level = int.tryParse(parts[1]) ?? 0;

      return LearnedSkill(skillId: skillId, skillLevel: level);
    });
  }

  bool canBeTrained({required Iterable<LearnedSkill> knownSkills}) {
    final reqSkill = requiredSkill;
    if (reqSkill == null) return true;
    // Only need the first here
    // As there is only one (so far)
    final preSkillLevel = knownSkills
            .firstWhereOrNull(
              (skill) => skill.skillId == reqSkill.skillId,
            )
            ?.skillLevel ??
        0;

    return preSkillLevel >= reqSkill.skillLevel;
  }
}

// ignore_for_file: constant_identifier_names

// This is OK - as these will all be refactored in the new package

abstract class Skills {
  ///
  ///
  ///
  static const FrigateCommand = 49110000001;
  static const AdvancedFrigateCommand = 49110000002;
  static const ExpertFrigateCommand = 49110000003;
  static const DestroyerCommand = 49110000004;
  static const AdvancedDestroyerCommand = 49110000005;
  static const ExpertDestroyerCommand = 49110000006;
  static const CruiserCommand = 49110000007;
  static const AdvancedCruiserCommand = 49110000008;
  static const ExpertCruiserCommand = 49110000009;
  static const BattlecruiserCommand = 49110000010;
  static const AdvancedBattlecruiserCommand = 49110000011;
  static const ExpertBattlecruiserCommand = 49110000012;
  static const BattleshipCommand = 49110000013;
  static const AdvancedBattleshipCommand = 49110000014;
  static const ExpertBattleshipCommand = 49110000015;
  static const IndustrialShipCommand = 49110000016;
  static const AdvancedIndustrialShipCommand = 49110000017;
  static const ExpertIndustrialShipCommand = 49110000018;

  ///
  ///
  ///
  static const Afterburner = 49120000001;
  static const AdvancedAfterburner = 49120000002;
  static const ExpertAfterburner = 49120000003;
  static const MicrowarpdriveOperation = 49120000004;
  static const AdvancedMicrowarpdriveOperation = 49120000005;
  static const ExpertMicrowarpdriveOperation = 49120000006;
  static const EngineOperation = 49120000007;
  static const AdvancedEngineOperation = 49120000008;
  static const ExpertEngineOperation = 49120000009;

  ///
  ///
  ///
  static const ShieldOperation = 49210000001;
  static const AdvancedShieldOperation = 49210000002;
  static const ExpertShieldOperation = 49210000003;
  static const ShieldHardening = 49210000004;
  static const AdvancedShieldHardening = 49210000005;
  static const ExpertShieldHardening = 49210000006;
  static const RemoteShieldOperation = 49210000007;
  static const AdvancedRemoteShieldOperation = 49210000008;
  static const ExpertRemoteShieldOperation = 49210000009;

  ///
  ///
  ///
  static const ArmorOperation = 49220000001;
  static const AdvancedArmorOperation = 49220000002;
  static const ExpertArmorOperation = 49220000003;
  static const ArmorHardening = 49220000004;
  static const AdvancedArmorHardening = 49220000005;
  static const ExpertArmorHardening = 49220000006;
  static const RemoteArmorOperation = 49220000007;
  static const AdvancedRemoteArmorOperation = 49220000008;
  static const ExpertRemoteArmorOperation = 49220000009;

  ///
  ///
  ///
  static const FrigateDefenseUpgrade = 49230000001;
  static const AdvancedFrigateDefenseUpgrade = 49230000002;
  static const ExpertFrigateDefenseUpgrade = 49230000003;
  static const DestroyerDefenseUpgrade = 49230000004;
  static const AdvancedDestroyerDefenseUpgrade = 49230000005;
  static const ExpertDestroyerDefenseUpgrade = 49230000006;
  static const CruiserDefenseUpgrade = 49230000007;
  static const AdvancedCruiserDefenseUpgrade = 49230000008;
  static const ExpertCruiserDefenseUpgrade = 49230000009;
  static const BattlecruiserDefenseUpgrade = 49230000010;
  static const AdvancedBattlecruiserDefenseUpgrade = 49230000011;
  static const ExpertBattlecruiserDefenseUpgrade = 49230000012;
  static const BattleshipDefenseUpgrade = 49230000013;
  static const AdvancedBattleshipDefenseUpgrade = 49230000014;
  static const ExpertBattleshipDefenseUpgrade = 49230000015;
  static const IndustrialShipDefenseUpgrade = 49230000016;
  static const AdvancedIndustrialShipDefenseUpgrade = 49230000017;
  static const ExpertIndustrialShipDefenseUpgrade = 49230000018;

  ///
  ///
  ///
  static const FrigateEngineering = 49310000001;
  static const AdvancedFrigateEngineering = 49310000002;
  static const ExpertFrigateEngineering = 49310000003;
  static const DestroyerEngineering = 49310000004;
  static const AdvancedDestroyerEngineering = 49310000005;
  static const ExpertDestroyerEngineering = 49310000006;
  static const CruiserEngineering = 49310000007;
  static const AdvancedCruiserEngineering = 49310000008;
  static const ExpertCruiserEngineering = 49310000009;
  static const BattlecruiserEngineering = 49310000010;
  static const AdvancedBattlecruiserEngineering = 49310000011;
  static const ExpertBattlecruiserEngineering = 49310000012;
  static const BattleshipEngineering = 49310000013;
  static const AdvancedBattleshipEngineering = 49310000014;
  static const ExpertBattleshipEngineering = 49310000015;
  static const IndustrialShipEngineering = 49310000016;
  static const AdvancedIndustrialShipEngineering = 49310000017;
  static const ExpertIndustrialShipEngineering = 49310000018;

  ///
  ///
  ///
  static const ElectronicWarfare = 49320000001;
  static const AdvancedElectronicWarfare = 49320000002;
  static const ExpertElectronicWarfare = 49320000003;
  static const PropulsionJamming = 49320000004;
  static const AdvancedPropulsionJamming = 49320000005;
  static const ExpertPropulsionJamming = 49320000006;
  static const SignalDisruption = 49320000007;
  static const AdvancedSignalDisruption = 49320000008;
  static const ExpertSignalDisruption = 49320000009;

  ///
  ///
  ///
  static const TargetManagement = 49330000001;
  static const AdvancedTargetManagement = 49330000002;
  static const ExpertTargetManagement = 49330000003;

  ///
  ///
  ///
  static const MiningForeman = 49340000001;
  static const AdvancedMiningForeman = 49340000002;
  static const ExpertMiningForeman = 49340000003;
  static const ShieldCommand = 49340000004;
  static const AdvancedShieldCommand = 49340000005;
  static const ExpertShieldCommand = 49340000006;
  static const InformationCommand = 49340000007;
  static const AdvancedInformationCommand = 49340000008;
  static const ExpertInformationCommand = 49340000009;
  static const SkirmishCommand = 49340000010;
  static const AdvancedSkirmishCommand = 49340000011;
  static const ExpertSkirmishCommand = 49340000012;
  static const ArmoredCommand = 49340000013;
  static const AdvancedArmoredCommand = 49340000014;
  static const ExpertArmoredCommand = 49340000015;

  ///
  ///
  ///
  static const SmallLaserOperation = 49410000001;
  static const AdvancedSmallLaserOperation = 49410000002;
  static const ExpertSmallLaserOperation = 49410000003;
  static const SmallLaserUpgrade = 49410000004;
  static const AdvancedSmallLaserUpgrade = 49410000005;
  static const ExpertSmallLaserUpgrade = 49410000006;
  static const MediumLaserOperation = 49410000007;
  static const AdvancedMediumLaserOperation = 49410000008;
  static const ExpertMediumLaserOperation = 49410000009;
  static const MediumLaserUpgrade = 49410000010;
  static const AdvancedMediumLaserUpgrade = 49410000011;
  static const ExpertMediumLaserUpgrade = 49410000012;
  static const LargeLaserOperation = 49410000013;
  static const AdvancedLargeLaserOperation = 49410000014;
  static const ExpertLargeLaserOperation = 49410000015;
  static const LargeLaserUpgrade = 49410000016;
  static const AdvancedLargeLaserUpgrade = 49410000017;
  static const ExpertLargeLaserUpgrade = 49410000018;

  ///
  ///
  ///
  static const SmallRailgunOperation = 49420000001;
  static const AdvancedSmallRailgunOperation = 49420000002;
  static const ExpertSmallRailgunOperation = 49420000003;
  static const SmallRailgunUpgrade = 49420000004;
  static const AdvancedSmallRailgunUpgrade = 49420000005;
  static const ExpertSmallRailgunUpgrade = 49420000006;
  static const MediumRailgunOperation = 49420000007;
  static const AdvancedMediumRailgunOperation = 49420000008;
  static const ExpertMediumRailgunOperation = 49420000009;
  static const MediumRailgunUpgrade = 49420000010;
  static const AdvancedMediumRailgunUpgrade = 49420000011;
  static const ExpertMediumRailgunUpgrade = 49420000012;
  static const LargeRailgunOperation = 49420000013;
  static const AdvancedLargeRailgunOperation = 49420000014;
  static const ExpertLargeRailgunOperation = 49420000015;
  static const LargeRailgunUpgrade = 49420000016;
  static const AdvancedLargeRailgunUpgrade = 49420000017;
  static const ExpertLargeRailgunUpgrade = 49420000018;

  ///
  ///
  ///
  static const SmallCannonOperation = 49430000001;
  static const AdvancedSmallCannonOperation = 49430000002;
  static const ExpertSmallCannonOperation = 49430000003;
  static const SmallCannonUpgrade = 49430000004;
  static const AdvancedSmallCannonUpgrade = 49430000005;
  static const ExpertSmallCannonUpgrade = 49430000006;
  static const MediumCannonOperation = 49430000007;
  static const AdvancedMediumCannonOperation = 49430000008;
  static const ExpertMediumCannonOperation = 49430000009;
  static const MediumCannonUpgrade = 49430000010;
  static const AdvancedMediumCannonUpgrade = 49430000011;
  static const ExpertMediumCannonUpgrade = 49430000012;
  static const LargeCannonOperation = 49430000013;
  static const AdvancedLargeCannonOperation = 49430000014;
  static const ExpertLargeCannonOperation = 49430000015;
  static const LargeCannonUpgrade = 49430000016;
  static const AdvancedLargeCannonUpgrade = 49430000017;
  static const ExpertLargeCannonUpgrade = 49430000018;

  ///
  ///
  ///
  static const SmallMissileTorpedoOperation = 49440000001;
  static const AdvancedSmallMissileTorpedoOperation = 49440000002;
  static const ExpertSmallMissileTorpedoOperation = 49440000003;
  static const SmallMissileTorpedoUpgrade = 49440000004;
  static const AdvancedSmallMissileTorpedoUpgrade = 49440000005;
  static const ExpertSmallMissileTorpedoUpgrade = 49440000006;
  static const MediumMissileTorpedoOperation = 49440000007;
  static const AdvancedMediumMissileTorpedoOperation = 49440000008;
  static const ExpertMediumMissileTorpedoOperation = 49440000009;
  static const MediumMissileTorpedoUpgrade = 49440000010;
  static const AdvancedMediumMissileTorpedoUpgrade = 49440000011;
  static const ExpertMediumMissileTorpedoUpgrade = 49440000012;
  static const LargeMissileTorpedoOperation = 49440000013;
  static const AdvancedLargeMissileTorpedoOperation = 49440000014;
  static const ExpertLargeMissileTorpedoOperation = 49440000015;
  static const LargeMissileTorpedoUpgrade = 49440000016;
  static const AdvancedLargeMissileTorpedoUpgrade = 49440000017;
  static const ExpertLargeMissileTorpedoUpgrade = 49440000018;

  ///
  ///
  ///
  static const SmallDroneOperation = 49450000001;
  static const AdvancedSmallDroneOperation = 49450000002;
  static const ExpertSmallDroneOperation = 49450000003;
  static const SmallDroneUpgrade = 49450000004;
  static const AdvancedSmallDroneUpgrade = 49450000005;
  static const ExpertSmallDroneUpgrade = 49450000006;
  static const MediumDroneOperation = 49450000007;
  static const AdvancedMediumDroneOperation = 49450000008;
  static const ExpertMediumDroneOperation = 49450000009;
  static const MediumDroneUpgrade = 49450000010;
  static const AdvancedMediumDroneUpgrade = 49450000011;
  static const ExpertMediumDroneUpgrade = 49450000012;
  static const LargeDroneOperation = 49450000013;
  static const AdvancedLargeDroneOperation = 49450000014;
  static const ExpertLargeDroneOperation = 49450000015;
  static const LargeDroneUpgrade = 49450000016;
  static const AdvancedLargeDroneUpgrade = 49450000017;
  static const ExpertLargeDroneUpgrade = 49450000018;
  static const Drone = 49450000019;
  static const AdvancedDrone = 49450000020;
  static const ExpertDrone = 49450000021;

  ///
  ///
  ///
  static const SmallDecomposerCommand = 49460000001;
  static const AdvancedSmallDecomposerCommand = 49460000002;
  static const ExpertSmallDecomposerCommand = 49460000003;
  static const SmallDecomposerUpgrade = 49460000004;
  static const AdvancedSmallDecomposerUpgrade = 49460000005;
  static const ExpertSmallDecomposerUpgrade = 49460000006;
  static const MediumDecomposerCommand = 49460000007;
  static const AdvancedMediumDecomposerCommand = 49460000008;
  static const ExpertMediumDecomposerCommand = 49460000009;
  static const MediumDecomposerUpgrade = 49460000010;
  static const AdvancedMediumDecomposerUpgrade = 49460000011;
  static const ExpertMediumDecomposerUpgrade = 49460000012;
  static const LargeDecomposerCommand = 49460000013;
  static const AdvancedLargeDecomposerCommand = 49460000014;
  static const ExpertLargeDecomposerCommand = 49460000015;
  static const LargeDecomposerUpgrade = 49460000016;
  static const AdvancedLargeDecomposerUpgrade = 49460000017;
  static const ExpertLargeDecomposerUpgrade = 49460000018;

  ///
  ///
  ///
  static const FrigateManufacture = 49510000011;
  static const AdvancedFrigateManufacture = 49510000012;
  static const ExpertFrigateManufacture = 49510000013;
  static const DestroyerManufacture = 49510000014;
  static const AdvancedDestroyerManufacture = 49510000015;
  static const ExpertDestroyerManufacture = 49510000016;
  static const CruiserManufacture = 49510000017;
  static const AdvancedCruiserManufacture = 49510000018;
  static const ExpertCruiserManufacture = 49510000019;
  static const BattlecruiserManufacture = 49510000020;
  static const AdvancedBattlecruiserManufacture = 49510000021;
  static const ExpertBattlecruiserManufacture = 49510000022;
  static const BattleshipManufacture = 49510000023;
  static const AdvancedBattleshipManufacture = 49510000024;
  static const ExpertBattleshipManufacture = 49510000025;
  static const IndustrialShipManufacture = 49510000026;
  static const AdvancedIndustrialShipManufacture = 49510000027;
  static const ExpertIndustrialShipManufacture = 49510000028;
  static const ModuleManufacture = 49510000101;
  static const AdvancedModuleManufacture = 49510000102;
  static const ExpertModuleManufacture = 49510000103;
  static const RigManufacture = 49510000104;
  static const AdvancedRigManufacture = 49510000105;
  static const ExpertRigManufacture = 49510000106;
  static const StructureConstruction = 49510000107;
  static const AdvancedStructureConstruction = 49510000108;
  static const ExpertStructureConstruction = 49510000109;

  ///
  ///
  ///
  static const Mining = 49520000001;
  static const AdvancedMining = 49520000002;
  static const ExpertMining = 49520000003;
  static const StripMining = 49520000004;
  static const AdvancedStripMining = 49520000005;
  static const ExpertStripMining = 49520000006;

  ///
  ///
  ///
  static const CommonOreReprocessing = 49530000001;
  static const AdvancedCommonOreReprocessing = 49530000002;
  static const ExpertCommonOreReprocessing = 49530000003;
  static const UncommonOreReprocessing = 49530000004;
  static const AdvancedUncommonOreReprocessing = 49530000005;
  static const ExpertUncommonOreReprocessing = 49530000006;
  static const SpecialOreReprocessing = 49530000007;
  static const AdvancedSpecialOreReprocessing = 49530000008;
  static const ExpertSpecialOreReprocessing = 49530000009;
  static const RareOreReprocessing = 49530000010;
  static const AdvancedRareOreReprocessing = 49530000011;
  static const ExpertRareOreReprocessing = 49530000012;
  static const PreciousOreReprocessing = 49530000013;
  static const AdvancedPreciousOreReprocessing = 49530000014;
  static const ExpertPreciousOreReprocessing = 49530000015;
  static const ScrapMetalProcessing = 49530000016;
  static const AdvancedScrapMetalProcessing = 49530000017;
  static const ExpertScrapMetalProcessing = 49530000018;

  ///
  ///
  ///
  static const CorporationManagement = 49610000001;
  static const AdvancedCorporationManagement = 49610000002;
  static const ExpertCorporationManagement = 49610000003;
  static const AllianceManagement = 49610000004;
  static const AdvancedAllianceManagement = 49610000005;
  static const ExpertAllianceManagement = 49610000006;

  ///
  ///
  ///
  static const Trade = 49620000001;
  static const AdvancedTrade = 49620000002;
  static const ExpertTrade = 49620000003;
  static const Accounting = 49620000004;
  static const AdvancedAccounting = 49620000005;
  static const ExpertAccounting = 49620000006;
  static const Freight = 49620000007;
  static const AdvancedFreight = 49620000008;
  static const ExpertFreight = 49620000009;

  ///
  ///
  ///
  static const AmarrInventionPrinciples = 49710000016;
  static const AdvancedAmarrInventionPrinciples = 49710000017;
  static const ExpertAmarrInventionPrinciples = 49710000018;
  static const CaldariInventionPrinciples = 49710000019;
  static const AdvancedCaldariInventionPrinciples = 49710000020;
  static const ExpertCaldariInventionPrinciples = 49710000021;
  static const GallenteInventionPrinciples = 49710000022;
  static const AdvancedGallenteInventionPrinciples = 49710000023;
  static const ExpertGallenteInventionPrinciples = 49710000024;
  static const MinmatarInventionPrinciples = 49710000025;
  static const AdvancedMinmatarInventionPrinciples = 49710000026;
  static const ExpertMinmatarInventionPrinciples = 49710000027;

  ///
  ///
  ///
  static const AngelInventionPrinciples = 49720000001;
  static const AdvancedAngelInventionPrinciples = 49720000002;
  static const ExpertAngelInventionPrinciples = 49720000003;
  static const BloodInventionPrinciples = 49720000004;
  static const AdvancedBloodInventionPrinciples = 49720000005;
  static const ExpertBloodInventionPrinciples = 49720000006;
  static const GuristasInventionPrinciples = 49720000007;
  static const AdvancedGuristasInventionPrinciples = 49720000008;
  static const ExpertGuristasInventionPrinciples = 49720000009;
  static const SerpentisInventionPrinciples = 49720000010;
  static const AdvancedSerpentisInventionPrinciples = 49720000011;
  static const ExpertSerpentisInventionPrinciples = 49720000012;
  static const SanshaInventionPrinciples = 49720000013;
  static const AdvancedSanshaInventionPrinciples = 49720000014;
  static const ExpertSanshaInventionPrinciples = 49720000015;
  static const OREInventionPrinciples = 49720000016;
  static const AdvancedOREInventionPrinciples = 49720000017;
  static const ExpertOREInventionPrinciples = 49720000018;
  static const MordusLegionInventionPrinciples = 49720000019;
  static const AdvancedMordusLegionInventionPrinciples = 49720000020;
  static const ExpertMordusLegionInventionPrinciples = 49720000021;
  static const SOEInventionPrinciples = 49720000022;
  static const AdvancedSOEInventionPrinciples = 49720000023;
  static const ExpertSOEInventionPrinciples = 49720000024;
  static const InterBusInventionPrinciples = 49720000025;
  static const AdvancedInterBusInventionPrinciples = 49720000026;
  static const ExpertInterBusInventionPrinciples = 49720000027;
  static const YanJungInventionPrinciples = 49720000028;
  static const AdvancedYanJungInventionPrinciples = 49720000029;
  static const ExpertYanJungInventionPrinciples = 49720000030;

  ///
  ///
  ///
  static const Planetology = 49810000001;
  static const AdvancedPlanetology = 49810000002;
  static const ExpertPlanetology = 49810000003;

  ///
  ///
  ///
  static const Archaeology = 49820000001;
  static const AdvancedArchaeology = 49820000002;
  static const ExpertArchaeology = 49820000003;
  static const Hacking = 49820000004;
  static const AdvancedHacking = 49820000005;
  static const ExpertHacking = 49820000006;

  ///
  ///
  ///
  static const CognitiveNeuroscience = 49830000001;
  static const AdvancedCognitiveNeuroscience = 49830000002;
  static const ExpertCognitiveNeuroscience = 49830000003;
  static const SuperAccelerationSkill = 49830000004;
}
