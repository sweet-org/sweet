// ignore_for_file: non_constant_identifier_names

import 'base_dao.dart';

mixin BaseDaoMixin<T> on BaseDao<T> {
  @override
  String? get tableConstraint => null;

  @override
  List<String> get ignoreKeys => [];

  @override
  Future<void> createTable() async {
    var definitions = columnDefinitions.entries
        .map(
          (e) => '${e.key} ${e.value}',
        )
        .join(',');

    if (tableConstraint?.isNotEmpty ?? false) {
      definitions += ', $tableConstraint';
    }

    var createStatement =
        'CREATE TABLE IF NOT EXISTS $tableName ( $definitions );';
    await db.db.execute(createStatement);
  }

  @override
  Future<void> dropTable() async {
    await db.db.execute('DROP TABLE IF EXISTS $tableName;');
  }

  @override
  Future<void> bulkInsert(Iterable<T> items) async {
    var batch = db.db.batch();

    for (var item in items) {
      var row = mapItemToRow(item);

      row.removeWhere((key, value) => ignoreKeys.contains(key));
      converters.forEach(
        (key, converter) => row[key] = converter.mapToDatabase(row[key]),
      );
      batch.insert(tableName, row);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> insert(T item) async {
    final row = mapItemToRow(item);

    row.removeWhere((key, value) => ignoreKeys.contains(key));
    converters.forEach(
      (key, converter) => row[key] = converter.mapToDatabase(row[key]),
    );

    await db.db.insert(tableName, row);
  }

  @override
  Future<Iterable<T>> selectAll() async => select();

  Future<Iterable<T>> select({String whereClause = ''}) =>
      select_raw(query: 'SELECT * FROM $tableName $whereClause;');

  Future<Iterable<T>> select_raw({required String query}) async {
    var e = await db.db.rawQuery(query).then((results) => results.map((row) {
          return convertRowToItem(row);
        }));

    return e;
  }

  T convertRowToItem(Map<String, dynamic> row) {
    var map = Map<String, dynamic>.from(row);
    converters.forEach(
      (key, converter) => map[key] = converter.mapFromDatabase(map[key]),
    );
    return mapRowToItem(map);
  }

  Future<T?> selectWithId({int? id}) async {
    var results = await select(whereClause: 'WHERE id = $id');

    return results.isNotEmpty ? results.first : null;
  }

  Future<Iterable<T>> selectWithIds({required Iterable<int> ids}) async =>
      await select(whereClause: 'WHERE id IN (${ids.join(', ')})');
}
