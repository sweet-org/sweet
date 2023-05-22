
import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/effect.dart';

class EffectDao extends BaseDao<Effect> with BaseDaoMixin {
  EffectDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'effects';

  @override
  Map<String, TypeConverter> converters = {
    'disallowAutoRepeat': BoolTypeConverter(),
    'electronicChance': BoolTypeConverter(),
    'isAssistance': BoolTypeConverter(),
    'isOffensive': BoolTypeConverter(),
    'isWarpSafe': BoolTypeConverter(),
    'rangeChance': BoolTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(Effect item) => item.toJson();

  @override
  Effect mapRowToItem(Map<String, dynamic> row) => Effect.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER NOT NULL PRIMARY KEY',
        'disallowAutoRepeat': 'INTEGER NOT NULL DEFAULT 0',
        'dischargeAttributeId': 'INTEGER NOT NULL DEFAULT 0',
        'durationAttributeId': 'INTEGER NOT NULL DEFAULT 0',
        'effectCategory': 'INTEGER NOT NULL DEFAULT 0',
        'effectName': 'TEXT NOT NULL',
        'electronicChance': 'INTEGER NOT NULL DEFAULT 0',
        'falloffAttributeId': 'INTEGER NOT NULL DEFAULT 0',
        'fittingUsageChanceAttributeId': 'INTEGER NOT NULL DEFAULT 0',
        'guid': 'TEXT NOT NULL',
        'isAssistance': 'INTEGER NOT NULL DEFAULT 0',
        'isOffensive': 'INTEGER NOT NULL DEFAULT 0',
        'isWarpSafe': 'INTEGER NOT NULL DEFAULT 0',
        'rangeAttributeId': 'INTEGER NOT NULL DEFAULT 0',
        'rangeChance': 'INTEGER NOT NULL DEFAULT 0',
        'trackingSpeedAttributeId': 'INTEGER NOT NULL DEFAULT 0',
      };
}
