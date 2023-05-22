

import 'dart:convert';

Map<String, List<LocalisedString>> localisedStringsFromMap(String str) =>
    Map<String, List<LocalisedString>>.from(json.decode(str).map((key, value) {
      return MapEntry(
          key,
          List<LocalisedString>.from(
              value.map((x) => LocalisedString.fromMap(map: x))));
    }));

class LocalisedString {
  final int index;
  final String localisedString;

  LocalisedString({required this.index, required this.localisedString});

  factory LocalisedString.fromMap({required Map<String, dynamic> map}) {
    return LocalisedString(
      index: map['index'],
      localisedString: map['localisedString'],
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'localisedString': localisedString,
      };
}
