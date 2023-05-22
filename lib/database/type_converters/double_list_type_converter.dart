import 'dart:convert';

import 'type_converter.dart';

class DoubleListTypeConverter extends TypeConverter<List<double?>, String> {
  @override
  List<double> mapFromDatabase(String databaseValue) =>
      List<double>.from(jsonDecode(databaseValue) ?? []);

  @override
  String mapToDatabase(List<double?> inputValue) => jsonEncode(inputValue);
}
