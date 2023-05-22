import 'type_converter.dart';

class BoolTypeConverter extends TypeConverter<bool?, int> {
  @override
  bool mapFromDatabase(int databaseValue) => databaseValue != 0;

  @override
  int mapToDatabase(bool? inputValue) => (inputValue ?? false) ? 1 : 0;
}
