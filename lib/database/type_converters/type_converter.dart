

abstract class TypeConverter<T, U> {
  U mapToDatabase(T inputValue);
  T mapFromDatabase(U databaseValue);
}
