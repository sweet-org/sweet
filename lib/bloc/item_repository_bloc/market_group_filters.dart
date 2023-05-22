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
        return 1020210;
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
        return 1020211;
      case MarketGroupFilters.lightweightFrigates:
        return 102021101;
      case MarketGroupFilters.lightweightDestroyers:
        return 102021102;

      case MarketGroupFilters.hangarRigs:
        return 105008000;

      default:
        assert(this == MarketGroupFilters.all, 'Unknown filter type: $this');
        return 0;
    }
  }
}
