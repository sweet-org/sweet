enum MarketGroupFilters {
  ship,
  highSlot,
  midSlot,
  lowSlot,
  drones,
  fighters,
  combatRigs,
  engineeringRigs,
  nanocores,
  blueprints,
  combatRigIntegrators,
  engineeringRigIntegrators,
  implants,
  lightweightFrigates,
  lightweightDestroyers,
  hangarRigs,

  lightweightShips,
  all,
  structures,
  pos,
  structureWeapons,
  structureModules,
  structureServices,

  advancedImplants,
  generalUnits,
  advancedUnits,
}

final kMidslotExcludeMarketGroups = [
  MarketGroupFilters.drones,
  MarketGroupFilters.fighters,
  MarketGroupFilters.lightweightFrigates,
  MarketGroupFilters.lightweightDestroyers,
];

final kMidslotExcludeMarketGroupIds = kMidslotExcludeMarketGroups.map(
  (e) => e.marketGroupId,
);

final kRigIntegratorMarketGroups = [
  MarketGroupFilters.combatRigIntegrators,
  MarketGroupFilters.engineeringRigIntegrators,
];

extension MarketGroupFilterExtension on MarketGroupFilters {
  int get marketGroupId {
    switch (this) {
      case MarketGroupFilters.ship:
        return 1000;
      case MarketGroupFilters.structures:
        return 1100;
      case MarketGroupFilters.pos:
        return 110000010;
      case MarketGroupFilters.structureWeapons:
        return 110001000;
      case MarketGroupFilters.structureModules:
        return 110001010;
      case MarketGroupFilters.structureServices:
        return 110001020;
      case MarketGroupFilters.highSlot:
        return 1010;
      case MarketGroupFilters.midSlot:
        return 1020;
      case MarketGroupFilters.lowSlot:
        return 1030;
      case MarketGroupFilters.combatRigs:
        return 1040;
      case MarketGroupFilters.engineeringRigs:
        return 1050;
      case MarketGroupFilters.drones:
        return 1020020;
      case MarketGroupFilters.fighters:
        return 1020030;
      case MarketGroupFilters.nanocores:
        return 3950;
      case MarketGroupFilters.blueprints:
        return 1700;
      case MarketGroupFilters.combatRigIntegrators:
        return 104007002;
      case MarketGroupFilters.engineeringRigIntegrators:
        return 105007000;
      case MarketGroupFilters.implants:
        return 2000;
      case MarketGroupFilters.lightweightShips:
        return 300001022;
      case MarketGroupFilters.lightweightFrigates:
        return 102003021;
      case MarketGroupFilters.lightweightDestroyers:
        return 102003022;

      case MarketGroupFilters.hangarRigs:
        return 1050080;

      case MarketGroupFilters.advancedImplants:
        return 2000040;
      case MarketGroupFilters.generalUnits:
        return 2000050;
      case MarketGroupFilters.advancedUnits:
        return 2000051;

      default:
        assert(this == MarketGroupFilters.all, 'Unknown filter type: $this');
        return 0;
    }
  }
}
