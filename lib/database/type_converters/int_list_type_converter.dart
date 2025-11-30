import 'dart:convert';

import 'type_converter.dart';

class IntListTypeConverter extends TypeConverter<List<int?>, String> {
  @override
  List<int> mapFromDatabase(String databaseValue) =>
      List<int>.from(jsonDecode(databaseValue) ?? []);

  @override
  String mapToDatabase(List<int?> inputValue) => jsonEncode(inputValue);
}

class IntNullableListTypeConverter extends TypeConverter<List<int>?, String?> {
  @override
  List<int>? mapFromDatabase(String? databaseValue) => databaseValue == null
      ? null
      : List<int>.from(jsonDecode(databaseValue) ?? []);

  @override
  String? mapToDatabase(List<int>? inputValue) => inputValue == null
      ? null
      : jsonEncode(inputValue);
}

class IntListListTypeConverter extends TypeConverter<List<List<int>>, String> {
  @override
  List<List<int>> mapFromDatabase(String databaseValue) {
    final list = List<List<int>>.from(
      jsonDecode(databaseValue).map(
        (x) => List<int>.from(
          x.map((x) => x),
        ),
      ),
    );
    return list;
  }

  @override
  String mapToDatabase(List<List<int>> inputValue) => jsonEncode(inputValue);
}
