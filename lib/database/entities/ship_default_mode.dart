

class ShipDefaultMode {
  final int shipId;
  final int modeId;

  ShipDefaultMode({
    required this.shipId,
    required this.modeId,
  });

  factory ShipDefaultMode.fromJson(Map<String, dynamic> json) =>
      ShipDefaultMode(
        shipId: json['shipId'],
        modeId: json['modeId'],
      );

  Map<String, dynamic> toJson() => {
        'shipId': shipId,
        'modeId': modeId,
      };
}
