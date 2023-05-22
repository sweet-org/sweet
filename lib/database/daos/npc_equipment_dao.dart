

import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/npc_equipment.dart';

class NpcEquipmentDao extends BaseDao<NpcEquipment> with BaseDaoMixin {
  NpcEquipmentDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'npc_equipment';

  @override
  Map<String, TypeConverter> converters = {
    'highslot': IntListTypeConverter(),
    'medslot': IntListTypeConverter(),
    'lowslot': IntListTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(NpcEquipment item) => item.toJson();

  @override
  NpcEquipment mapRowToItem(Map<String, dynamic> row) =>
      NpcEquipment.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'highslot': 'TEXT NOT NULL',
        'medslot': 'TEXT NOT NULL',
        'lowslot': 'TEXT NOT NULL'
      };
}
