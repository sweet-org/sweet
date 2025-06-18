import 'dart:async';

import '../entities/entities.dart';

import '../../util/murmur32.dart';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

class LocalisedStringDao extends BaseDao<LocalisationEntry> with BaseDaoMixin {
  LocalisedStringDao(super.db);

  @override
  String get tableName => 'localised_strings';

  @override
  Map<String, TypeConverter> get converters => {};

  @override
  Map<String, dynamic> mapItemToRow(LocalisationEntry item) => item.toJson();

  @override
  LocalisationEntry mapRowToItem(Map<String, dynamic> row) =>
      LocalisationEntry.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'source': 'TEXT',
        'en': 'TEXT',
        'de': 'TEXT',
        'fr': 'TEXT',
        'ja': 'TEXT',
        'kr': 'TEXT',
        'por': 'TEXT',
        'ru': 'TEXT',
        'spa': 'TEXT',
        'zh': 'TEXT',
        'zhcn': 'TEXT',
      };

  static final _mmh = Murmur32(2538058380);
  Future<String> getLocalisedStringForItem({
    required Item item,
    required String langCode,
  }) async {
    final source = item.sourceName ?? '';
    final regEx = RegExp(r'{(([^:}])*):(?<source>([^}])*)}');
    final match = regEx.allMatches(source);

    final sourceStrings = <String>[];
    if (match.isNotEmpty) {
    } else {
      sourceStrings.add(source);
    }

    final hashes = sourceStrings.map(
      (e) => _mmh.computeHashFromString(e).getUint32(0),
    );

    final results = await db.db.rawQuery(
      'SELECT id, source, $langCode FROM $tableName WHERE id IN ${hashes.join(',')}',
    );

    if (results.isNotEmpty) {
      final string = results
          .map(
            (e) => mapRowToItem(e),
          )
          .map(
            (e) => e.en,
          )
          .join(
            ' ',
          );
      return string;
    }

    return '[Unknown String]';
  }

  Future<String?> getLocalisedStringForId({
    required int id,
    required String langCode,
  }) async {
    var results = await db.db
        .rawQuery('SELECT source, $langCode FROM $tableName WHERE id = $id');

    if (results.isEmpty) return null;

    return results.first[langCode] as FutureOr<String?>? ??
        results.first['source'] as FutureOr<String?>;
  }
}
