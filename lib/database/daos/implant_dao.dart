import '../entities/implant.dart';
import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

class ImplantDao extends BaseDao<Implant> with BaseDaoMixin {
  ImplantDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'implants';

  @override
  Map<String, TypeConverter> converters = {
    'implantFramework': StringToIntListMapTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(Implant item) => item.toJson();

  @override
  Implant mapRowToItem(Map<String, dynamic> row) =>
      Implant.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'originalTypeId': 'INTEGER NULL',
        'rarity': 'INTEGER NULL',
        'implantType': 'INTEGER NULL',
        'implantFramework': 'TEXT NULL',
      };
}
