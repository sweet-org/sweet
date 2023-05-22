

import '../fitting/fitting_item.dart';
import '../modifier_change_type.dart';

class Modifier {
  final double modifierValue;
  final int attributeId;
  final ModifierChangeType changeScope;
  final String changeRange;
  final FittingItem item;
  
  Modifier({
    required this.modifierValue,
    required this.attributeId,
    required this.changeScope,
    required this.changeRange, // Cal code paths - i.e /Turr/ affects all with prefix
    required this.item,
  });
}
