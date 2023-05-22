

import '../database.dart';
import '../type_converters/type_converter.dart';

abstract class BaseDao<T> {
  final EveEchoesDatabase db;
  BaseDao(this.db);

  String get tableName;
  Map<String, String> get columnDefinitions;
  Iterable<String> get columnNames => columnDefinitions.keys;

  Map<String, TypeConverter> get converters;
  String? get tableConstraint;
  List<String> get ignoreKeys;

  Future<void> createTable();
  Future<void> dropTable();

  Future<void> insert(T item);
  Future<void> bulkInsert(Iterable<T> items);

  Future<Iterable<T>> selectAll();

  T mapRowToItem(Map<String, dynamic> row);
  Map<String, dynamic> mapItemToRow(T item);
}
