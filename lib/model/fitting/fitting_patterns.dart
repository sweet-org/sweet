import 'dart:convert';

class FittingPatterns {
  FittingPatterns({
    required this.damage,
    required this.defence,
  });

  List<FittingPattern> damage;
  List<FittingPattern> defence;

  factory FittingPatterns.fromRawJson(String str) =>
      FittingPatterns.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FittingPatterns.fromJson(Map<String, dynamic> json) =>
      FittingPatterns(
        damage: List<FittingPattern>.from(
            json['damage'].map((x) => FittingPattern.fromJson(x))),
        defence: List<FittingPattern>.from(
            json['defence'].map((x) => FittingPattern.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'damage': List<dynamic>.from(damage.map((x) => x.toJson())),
        'defence': List<dynamic>.from(defence.map((x) => x.toJson())),
      };
}

class FittingPattern {
  FittingPattern({
    required this.name,
    required this.emPercent,
    required this.thermalPercent,
    required this.kineticPercent,
    required this.explosivePercent,
  });

  final String name;
  final double emPercent;
  final double thermalPercent;
  final double kineticPercent;
  final double explosivePercent;

  factory FittingPattern.fromRawJson(String str) =>
      FittingPattern.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FittingPattern.fromJson(Map<String, dynamic> json) => FittingPattern(
        name: json['name'],
        emPercent: json['emPercent'].toDouble(),
        thermalPercent: json['thermalPercent'].toDouble(),
        kineticPercent: json['kineticPercent'].toDouble(),
        explosivePercent: json['explosivePercent'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'emPercent': emPercent,
        'thermalPercent': thermalPercent,
        'kineticPercent': kineticPercent,
        'explosivePercent': explosivePercent,
      };

  static FittingPattern get uniform => FittingPattern(
        name: 'Uniform',
        emPercent: 0.25,
        thermalPercent: 0.25,
        kineticPercent: 0.25,
        explosivePercent: 0.25,
      );
}
