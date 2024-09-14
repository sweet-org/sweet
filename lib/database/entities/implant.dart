import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';


part 'implant.g.dart';

List<Implant> implantsFromMap(String str) =>
    List<Implant>.from(json.decode(str).map((x) => Implant.fromJson(x)));

@JsonSerializable(includeIfNull: true)
class Implant {

  const Implant({
    required this.id,
    required this.originalTypeId,
    required this.rarity,
    required this.implantType,
    required this.implantFramework,
  });

  final int id;
  final int originalTypeId;
  final int rarity;
  final int implantType;
  final Map<String, List<int>> implantFramework;

  factory Implant.fromJson(Map<String, dynamic> json) =>
      _$ImplantFromJson(json);

  Map<String, dynamic> toJson() => _$ImplantToJson(this);
}