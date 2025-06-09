import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';

enum SlotType {
  implantSlots,
  high,
  mid,
  low,
  combatRig,
  engineeringRig,
  drone,
  nanocore,
  lightFFSlot,
  lightDDSlot,
  lightCASlot,
  lightBCSlot,
  //lightBBSlot,
  hangarRigSlots,
}

extension SlotTypeExtensions on SlotType {
  MarketGroupFilters get marketGroupFilter {
    switch (this) {
      case SlotType.high:
        return MarketGroupFilters.highSlot;
      case SlotType.mid:
        return MarketGroupFilters.midSlot;
      case SlotType.low:
        return MarketGroupFilters.lowSlot;
      case SlotType.combatRig:
        return MarketGroupFilters.combatRigs;
      case SlotType.engineeringRig:
        return MarketGroupFilters.engineeringRigs;
      case SlotType.drone:
        return MarketGroupFilters.drones;
      case SlotType.nanocore:
        return MarketGroupFilters.nanocores;

      case SlotType.lightFFSlot:
        return MarketGroupFilters.lightweightFrigates;
      case SlotType.lightDDSlot:
        return MarketGroupFilters.lightweightDestroyers;
      case SlotType.lightCASlot:
        return MarketGroupFilters.lightweightCruisers;
      case SlotType.lightBCSlot:
        return MarketGroupFilters.lightweightBattlecruisers;
      // case SlotType.lightBBSlot:
      //   return MarketGroupFilters.all;
      case SlotType.implantSlots:
        return MarketGroupFilters.implants;

      case SlotType.hangarRigSlots:
        return MarketGroupFilters.hangarRigs;
    }
  }
}
