import 'package:sweet/database/entities/entities.dart';

import 'fitting_item.dart';

class FittingSkill extends FittingItem {
  final int skillLevel;

  FittingSkill({
    required this.skillLevel,
    required Item item,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
  }) : super(
          item: item,
          baseAttributes: baseAttributes,
          modifiers: modifiers,
        );

  FittingSkill copyWith({required int skillLevel}) => FittingSkill(
        skillLevel: skillLevel,
        item: item,
        baseAttributes: baseAttributes,
        modifiers: modifiers,
      );
}
