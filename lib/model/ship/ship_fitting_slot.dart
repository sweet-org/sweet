import 'package:equatable/equatable.dart';
import 'package:sweet/model/ship/ship_fitting_slot_module.dart';

class ShipFittingSlot with EquatableMixin {
  int get maxSlots => _maxSlots;
  var _maxSlots = 0;
  List<ShipFittingSlotModule> get modules => _modules;
  List<ShipFittingSlotModule> _modules = [];

  int get numberOfFilledSlots => modules.where((e) => e.moduleId > 0).length;

  static ShipFittingSlot get empty => ShipFittingSlot(maxSlots: 0);
  ShipFittingSlot({
    required int maxSlots,
    List<ShipFittingSlotModule>? modules,
  })  : _maxSlots = maxSlots,
        _modules = modules ??
            List.filled(
              maxSlots,
              ShipFittingSlotModule.empty,
            );

  factory ShipFittingSlot.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return ShipFittingSlot.empty;

    final maxSlots = json['maxSlots'] as int? ?? 0;
    var modules =
        json['modules']?.map((map) => ShipFittingSlotModule.fromJson(map));

    modules ??= List.filled(
      maxSlots,
      ShipFittingSlotModule.empty,
    );

    return ShipFittingSlot(
      maxSlots: maxSlots,
      modules: List<ShipFittingSlotModule>.from(modules),
    );
  }

  void updateSlotCount({required int maxSlots}) {
    var modules = List<ShipFittingSlotModule>.from(this.modules);

    if (maxSlots == 0) {
      modules = [];
    } else if (modules.length > maxSlots) {
      modules = modules.sublist(0, maxSlots);
    } else if (modules.length < maxSlots) {
      final diff = maxSlots - modules.length;
      for (var i = 0; i < diff; i++) {
        modules.add(ShipFittingSlotModule.empty);
      }
    }
    _maxSlots = maxSlots;

    _modules = modules;
  }

  ShipFittingSlot copy() => ShipFittingSlot(
        maxSlots: maxSlots,
        modules: modules.map((e) => e.copy()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'maxSlots': maxSlots,
        'modules': modules,
      };

  @override
  List<Object> get props => [
        maxSlots,
        modules,
      ];
}
