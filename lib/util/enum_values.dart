class EnumValues<T> {
  final Map<String, T> _map;
  Map<T, String>? _reverseMap;

  EnumValues(this._map);

  T? operator [](String key) {
    if (!_map.containsKey(key)) {
      print('Key is missing $key');
      return null;
    }
    return _map[key];
  }

  Map<T, String> get reverse {
    _reverseMap ??= _map.map((k, v) => MapEntry(v, k));
    return _reverseMap!;
  }
}
