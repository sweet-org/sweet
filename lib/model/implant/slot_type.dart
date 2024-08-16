enum ImplantSlotType {
  branch, common, upgrade
}

extension TypeIdExtension on ImplantSlotType {
  int get typeId {
    switch (this) {
      case ImplantSlotType.branch:
        return 1;
      case ImplantSlotType.common:
        return 2;
      case ImplantSlotType.upgrade:
        return 3;
    }
  }
}