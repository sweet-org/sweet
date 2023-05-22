

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

List<Unit> unitsFromJson(String str) =>
    List<Unit>.from(json.decode(str).map((x) => Unit.fromJson(x)));

@JsonSerializable(includeIfNull: true)
class Unit {
  Unit({
    required this.id,
    this.description,
    this.displayName,
    required this.unitName,
  });

  final int id;
  final String? description;
  final String? displayName;
  final String unitName;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
