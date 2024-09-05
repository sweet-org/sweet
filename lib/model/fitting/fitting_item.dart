import 'package:sweet/database/entities/entities.dart';
import '../ship/modifier.dart';

class FittingItem {
  final Item item;

  int get itemId => item.id;
  int get groupId => item.groupId;
  int get categoryId => item.categoryId;

  int get marketGroupId => item.marketGroupId ?? -1;
  int get rootMarketGroupId => marketGroupId ~/ 100000;

  bool get excludeInCapacitorSimulation => item.excludeInCapacitorSimulation;

  List<String> get mainCalCode => [item.mainCalCode ?? ''];
  List<String> get activeCalCode => [item.activeCalCode ?? item.onlineCalCode ?? ''];

  final List<Attribute> baseAttributes;
  final List<ItemModifier> modifiers;
  final List<Modifier> selfModifiers = [];

  static FittingItem empty = FittingItem(
    item: Item.invalid,
    baseAttributes: [],
    modifiers: [],
  );

  FittingItem({
    required this.item,
    required this.baseAttributes,
    required this.modifiers,
  });
}
