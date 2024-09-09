
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (length == 0) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
