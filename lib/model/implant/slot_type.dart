enum ImplantSlotType {
  core, branch, common, upgrade, slave, disabled
}

extension TypeIdExtension on ImplantSlotType {
  int get typeId {
    switch (this) {
      case ImplantSlotType.core:
        return 0;
      case ImplantSlotType.branch:
        return 1;
      case ImplantSlotType.common:
        return 2;
      case ImplantSlotType.upgrade:
        return 3;
      case ImplantSlotType.slave:
        return 4;
      case ImplantSlotType.disabled:
        return 5;
    }
  }
}