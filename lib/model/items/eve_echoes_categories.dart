enum EveEchoesCategory {
  drones,
  ships,
  modules,
  fighters,
  skills,
  minerals,
  planetaryResources,
  nanocores,
  nanocoreAttributes,
  shipBlueprint,
  moduleBlueprint,
  subsystemBlueprint,
  chargeBlueprint,
  droneBlueprint,
  fighterBlueprint,
  implantBlueprint,
  deployableBlueprint,
  starbaseBlueprint,
  sovereigntyStructuresBlueprint,
  infrastructureUpgradesBlueprint,
  orbitalsBlueprint,
  structureBlueprint,
  structureModuleBlueprint,
  commodityBlueprint,
  accessoriesBlueprint,
  structure,
}

extension CategoryIdExtension on EveEchoesCategory {
  int get categoryId {
    switch (this) {
      case EveEchoesCategory.drones:
        return 14;
      case EveEchoesCategory.fighters:
        return 15;
      case EveEchoesCategory.ships:
        return 10;
      case EveEchoesCategory.modules:
        return 11;
      case EveEchoesCategory.structure:
        return 23;
      case EveEchoesCategory.skills:
        return 49;
      case EveEchoesCategory.minerals:
        return 41;
      case EveEchoesCategory.planetaryResources:
        return 42;
      case EveEchoesCategory.nanocores:
        return 81;
      case EveEchoesCategory.nanocoreAttributes:
        return 82;

      case EveEchoesCategory.shipBlueprint:
        return 60;
      case EveEchoesCategory.moduleBlueprint:
        return 61;
      case EveEchoesCategory.subsystemBlueprint:
        return 62;
      case EveEchoesCategory.chargeBlueprint:
        return 63;
      case EveEchoesCategory.droneBlueprint:
        return 64;
      case EveEchoesCategory.fighterBlueprint:
        return 65;
      case EveEchoesCategory.implantBlueprint:
        return 66;
      case EveEchoesCategory.deployableBlueprint:
        return 67;
      case EveEchoesCategory.starbaseBlueprint:
        return 68;
      case EveEchoesCategory.sovereigntyStructuresBlueprint:
        return 69;
      case EveEchoesCategory.infrastructureUpgradesBlueprint:
        return 70;
      case EveEchoesCategory.orbitalsBlueprint:
        return 71;
      case EveEchoesCategory.structureBlueprint:
        return 73;
      case EveEchoesCategory.structureModuleBlueprint:
        return 74;
      case EveEchoesCategory.commodityBlueprint:
        return 77;
      case EveEchoesCategory.accessoriesBlueprint:
        return 78;
    }
  }
}

const kBlueprintCategories = [
  EveEchoesCategory.shipBlueprint,
  EveEchoesCategory.moduleBlueprint,
  EveEchoesCategory.droneBlueprint,
  EveEchoesCategory.chargeBlueprint,
  EveEchoesCategory.fighterBlueprint,
  EveEchoesCategory.implantBlueprint,
  EveEchoesCategory.starbaseBlueprint,
  EveEchoesCategory.subsystemBlueprint,
  EveEchoesCategory.deployableBlueprint,
  EveEchoesCategory.commodityBlueprint,
  EveEchoesCategory.structureBlueprint,
  EveEchoesCategory.accessoriesBlueprint,
  EveEchoesCategory.structureModuleBlueprint,
  EveEchoesCategory.sovereigntyStructuresBlueprint,
  EveEchoesCategory.infrastructureUpgradesBlueprint,
];

enum EveEchoesGroup {
  propulsion,
  fighters,
  rigHybridWeapon,
  rigEnergyWeapon,
  rigProjectileWeapon,
  rigDecomposerWeapon,
  rigMissile,
  rigSheld,
  rigArmor,
  rigStructure,
  rigNavigation,
  rigCore,
  rigElectronicSystems,
  rigResourceProcessing,
  rigScanning,
  rigTargeting,
  rigScrambling,
  rigMining,
  rigAnchor,
  rigDrones,
  rigEnergyIntegrator,
  rigMachineryIntegrator,
}

const kRigIntegrators = [
  EveEchoesGroup.rigEnergyIntegrator,
  EveEchoesGroup.rigMachineryIntegrator,
];

const kNormalRigGroups = [
  EveEchoesGroup.rigHybridWeapon,
  EveEchoesGroup.rigEnergyWeapon,
  EveEchoesGroup.rigProjectileWeapon,
  EveEchoesGroup.rigDecomposerWeapon,
  EveEchoesGroup.rigMissile,
  EveEchoesGroup.rigSheld,
  EveEchoesGroup.rigArmor,
  EveEchoesGroup.rigStructure,
  EveEchoesGroup.rigNavigation,
  EveEchoesGroup.rigCore,
  EveEchoesGroup.rigElectronicSystems,
  EveEchoesGroup.rigResourceProcessing,
  EveEchoesGroup.rigScanning,
  EveEchoesGroup.rigTargeting,
  EveEchoesGroup.rigScrambling,
  EveEchoesGroup.rigMining,
  EveEchoesGroup.rigAnchor,
  EveEchoesGroup.rigDrones,
];

extension GroupIdExtension on EveEchoesGroup {
  int get groupId {
    switch (this) {
      case EveEchoesGroup.propulsion:
        return 11304;
      case EveEchoesGroup.fighters:
        return 14600;

      case EveEchoesGroup.rigHybridWeapon:
        return 11700;
      case EveEchoesGroup.rigEnergyWeapon:
        return 11702;
      case EveEchoesGroup.rigProjectileWeapon:
        return 11704;
      case EveEchoesGroup.rigDecomposerWeapon:
        return 11705;
      case EveEchoesGroup.rigMissile:
        return 11706;
      case EveEchoesGroup.rigSheld:
        return 11707;
      case EveEchoesGroup.rigArmor:
        return 11708;
      case EveEchoesGroup.rigStructure:
        return 11709;
      case EveEchoesGroup.rigNavigation:
        return 11710;
      case EveEchoesGroup.rigCore:
        return 11711;
      case EveEchoesGroup.rigElectronicSystems:
        return 11712;
      case EveEchoesGroup.rigResourceProcessing:
        return 11713;
      case EveEchoesGroup.rigScanning:
        return 11714;
      case EveEchoesGroup.rigTargeting:
        return 11715;
      case EveEchoesGroup.rigScrambling:
        return 11716;
      case EveEchoesGroup.rigMining:
        return 11717;
      case EveEchoesGroup.rigAnchor:
        return 11718;
      case EveEchoesGroup.rigDrones:
        return 11719;

      case EveEchoesGroup.rigEnergyIntegrator:
        return 11720;
      case EveEchoesGroup.rigMachineryIntegrator:
        return 11721;
    }
  }
}
