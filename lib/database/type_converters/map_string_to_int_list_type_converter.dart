import 'dart:convert';

import 'type_converter.dart';

class StringToIntListMapTypeConverter extends TypeConverter<Map<String, List<int?>>, String> {
  @override
  Map<String, List<int>> mapFromDatabase(String databaseValue) {
    final data = jsonDecode(databaseValue);
    final converted = data.map(
            (key, val) => MapEntry(key, val.cast<int>())
    );
    print("Test converted");
    return Map<String, List<int>>.from(converted ?? {});
  }

  @override
  String mapToDatabase(Map<String, List<int?>> inputValue) => jsonEncode(inputValue);
}

