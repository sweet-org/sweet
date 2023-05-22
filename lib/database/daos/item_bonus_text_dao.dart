

import '../database.dart';
import '../type_converters/type_converter.dart';
import '../entities/item_bonus_text.dart';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

class ItemBonusTexDao extends BaseDao<ItemBonusText> with BaseDaoMixin {
  ItemBonusTexDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'item_bonus_text';

  @override
  Map<String, TypeConverter> get converters => {};

  @override
  Map<String, dynamic> mapItemToRow(ItemBonusText item) => item.toJson();

  @override
  ItemBonusText mapRowToItem(Map<String, dynamic> row) =>
      ItemBonusText.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'localisedTextId': 'INTEGER NOT NULL',
      };
}
