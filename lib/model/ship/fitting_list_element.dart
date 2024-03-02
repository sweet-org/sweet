
import 'package:sweet/model/ship/ship_fitting_folder.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';

abstract class FittingListElement {
  String getId();
  String getName();
  Map<String, dynamic> toJson();

  factory FittingListElement.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null || json['type'] == 'LOADOUT') {
      return ShipFittingLoadout.fromJson(json);
    } else if (json['type'] == "FOLDER") {
      return ShipFittingFolder.fromJson(json);
    } else {
      print('Unknown json object $json');
      throw FormatException('Unknown JSON FittingListElement type: ${json["type"]}');
    }
  }
}
