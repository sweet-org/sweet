enum ImplantSlotType {
  core,
  branch,
  common,
  upgrade,
  slave,
  slaveCommon,
  @Deprecated("Is no longer required")
  // ToDo: Can't remember why I did even add this, got replaced with slave_common I think
  disabled
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
      case ImplantSlotType.slaveCommon:
        return 5;
      case ImplantSlotType.disabled:
        return -1;
    }
  }
}