

import 'dart:convert';

import 'modifier_definition.dart';
import 'modifier_value.dart';

ModifierCodes modifierCodesFromJson(String str) =>
    ModifierCodes.fromJson(json.decode(str));

class ModifierCodes {
  ModifierCodes({
    required this.code,
    required this.meta,
    this.skillCodeKeys = const [],
  });

  final Map<String, ModifierValues> code;
  final Map<String, ModifierDefinition> meta;
  final List<String> skillCodeKeys;

  factory ModifierCodes.fromJson(Map<String, dynamic> json) => ModifierCodes(
        code: Map.from(json['code']).map((k, v) {
          v['code'] = k;
          return MapEntry<String, ModifierValues>(
              k, ModifierValues.fromJson(v));
        }),
        meta: Map.from(json['meta']).map((k, v) {
          v['code'] = k;
          return MapEntry<String, ModifierDefinition>(
              k, ModifierDefinition.fromJson(v));
        }),
        skillCodeKeys: List<String>.from(json['skill_code_keys'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'code': Map.from(code)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        'meta': Map.from(meta)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        'skill_code_keys': List<dynamic>.from(skillCodeKeys.map((x) => x)),
      };
}
