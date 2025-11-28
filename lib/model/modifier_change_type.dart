// ignore_for_file: constant_identifier_names

// This is OK - as these will all be refactored in the new package

import '../util/enum_values.dart';

enum ModifierChangeType {
  MODULE,
  SHIP,
  SELF,
  DRONEMODULE,
  DRONE,
  TARGET,
  CHARACTER,
  STRUCTURE,
  // ToDo: Maybe implement STRUCTURE_MODULE ??
  STRUCTURE_MODULE,
  TARGET_MODULE,
  // ToDo: Find out what this is for (doomsday weapons? only a single modifier exists at time of writing)
  TARGET_DRONE_MODULE,
  IMPLANT,
  FILM,
  SUB_IMPLANT,
}

final changeTypeValues = EnumValues({
  'character': ModifierChangeType.CHARACTER,
  'drone': ModifierChangeType.DRONE,
  'dronemodule': ModifierChangeType.DRONEMODULE,
  'module': ModifierChangeType.MODULE,
  'self': ModifierChangeType.SELF,
  'ship': ModifierChangeType.SHIP,
  'structure': ModifierChangeType.STRUCTURE,
  'structuremodule': ModifierChangeType.STRUCTURE_MODULE,
  'target': ModifierChangeType.TARGET,
  'target_module': ModifierChangeType.TARGET_MODULE,
  'targetModule': ModifierChangeType.TARGET_MODULE,
  'targetDroneModule': ModifierChangeType.TARGET_DRONE_MODULE,
  'implant': ModifierChangeType.IMPLANT,
  'film': ModifierChangeType.FILM,
  'subImplant': ModifierChangeType.SUB_IMPLANT,
});
