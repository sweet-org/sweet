

import 'dart:convert';

import 'type_converter.dart';

class StringListTypeConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> mapFromDatabase(String databaseValue) =>
      List<String>.from(jsonDecode(databaseValue) ?? []);

  @override
  String mapToDatabase(List<String> inputValue) => jsonEncode(inputValue);
}
