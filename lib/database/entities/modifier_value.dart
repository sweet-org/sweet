class ModifierValues {
  ModifierValues({
    required this.code,
    required this.attributes,
    required this.typeName,
  });

  final String code;
  final List<double?> attributes;
  final String typeName;

  factory ModifierValues.fromJson(Map<String, dynamic> json) => ModifierValues(
        code: json['code'],
        attributes:
            List<double>.from(json['attributes'].map((x) => x?.toDouble())),
        typeName: json['typeName'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'attributes': List<double?>.from(attributes.map((x) => x)),
        'typeName': typeName,
      };
}
