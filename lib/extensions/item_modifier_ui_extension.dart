import 'package:sweet/database/database_exports.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';

extension ItemUI on ItemModifier {
  Future<String> modifierName({
    required LocalisationRepository localisation,
    required ItemRepository itemRepository,
  }) async {
    final attribute = await itemRepository.attributeWithId(id: attributeId);

    if (attribute == null) {
      return '[UNKNOWN]';
    }
    // Title builds by change range item (tips_attrs) + attribute name
    final moduleName =
        localisation.getLocalisedStringForIndex(changeRangeModuleNameId);
    final attributeName = localisation.getLocalisedNameForAttribute(attribute);

    final attributeUnit = localisation.getLocalisedUnitForAttribute(attribute);

    final bonusValue = attribute.calculatedValue(fromValue: attributeValue);
    var bonusAmount = '${bonusValue.toStringAsFixed(2)}$attributeUnit';

    if (!bonusValue.isNegative) {
      bonusAmount = '+$bonusAmount';
    }

    return '$bonusAmount $moduleName $attributeName';
  }
}
