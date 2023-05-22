import 'dart:math';

import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_ship.dart';
import 'package:sweet/model/ship/capacitor_simulation_results.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/util/constants.dart';

class CapacitorSimulator {
  final AttributeCalculatorService attributeCalculatorService;
  final FittingShip ship;

  CapacitorSimulator({
    required this.attributeCalculatorService,
    required this.ship,
  });

  ///
  /// Cap Simulation Details
  ///

  Future<CapacitorSimulationResults> simulate({
    required ItemRepository itemRepository,
    required Iterable<FittingModule> allFittedModules,
  }) async {
    var capacitorCapacity = attributeCalculatorService.getValueForItem(
        attribute: EveEchoesAttribute.capacitorCapacity, item: ship);
    var rechargeTime = attributeCalculatorService.getValueForItem(
        attribute: EveEchoesAttribute.capacitorRechargeTime, item: ship);

    var fittedModules = allFittedModules.where((e) =>
        e.state != ModuleState.inactive && !e.excludeInCapacitorSimulation);

    var totalCapNeed = 0.0;
    var modules = <ModuleCapacitorData>[];

    // There's this thing about 'flags' but it's only in relation to Charges/ammo?
    // In the TO DO LATER pile
    for (var module in fittedModules) {
      var defaultEffect =
          await itemRepository.getDefaultEffect(id: module.itemId);
      if (defaultEffect == null) {
        continue;
      }

      var durationAttributeId = defaultEffect.durationAttributeId;
      var dischargeAttributeId = defaultEffect.dischargeAttributeId;

      var duration = attributeCalculatorService.getValueForItemWithAttributeId(
        item: module,
        attributeId: durationAttributeId,
      );

      var reactivationDelay = attributeCalculatorService.getValueForItem(
        item: module,
        attribute: EveEchoesAttribute.moduleReactivationDelay,
      );

      var avgCapNeed = 0.0;
      var capNeed = 0.0;
      if (module.groupId == 11312) {
        // CapacitorBooster
        // Not in the game?
        continue;
      } else if (module.groupId == 11031) {
        // EnergyNosferatu
        var transferAmount = attributeCalculatorService.getValueForItem(
          item: module,
          attribute: EveEchoesAttribute.powerTransferAmount,
        );
        avgCapNeed = capNeed = -transferAmount;
      } else if (dischargeAttributeId ==
          EveEchoesAttribute.fuelNeed.attributeId) {
        // FuelNeed attribute does not use cap
        // But group items could give some cap, so we account for this
        if (kGroupRepairersHealSelf) {
          var transferAmount = attributeCalculatorService.getValueForItem(
            item: module,
            attribute: EveEchoesAttribute.powerTransferAmount,
          );
          avgCapNeed = capNeed = -transferAmount;
        } else {
          avgCapNeed = capNeed = 0;
        }
      } else {
        avgCapNeed =
            capNeed = attributeCalculatorService.getValueForItemWithAttributeId(
          item: module,
          attributeId: dischargeAttributeId,
        );
      }

      var k = ModuleCapacitorData(
        capNeeded: capNeed,
        durationValue: duration,
        reactivationDelay: reactivationDelay,
      );
      modules.add(k);
      totalCapNeed += avgCapNeed / (duration + reactivationDelay);
    }

    var rechargeRateAverage = capacitorCapacity / rechargeTime;
    var peakRechargeRate = 2.5 * rechargeRateAverage;
    var tau = rechargeTime / 5;
    var totalPositiveCapNeeded = max(0, totalCapNeed);
    double? capTTL;
    var shouldRunSimulation = totalCapNeed > peakRechargeRate;

    var loadBalance = -1.0;

    if (shouldRunSimulation || totalCapNeed / peakRechargeRate > 0.95) {
      capTTL = runCapacitorSimulation(
        capacitorCapacity,
        rechargeTime,
        modules,
      );

      capTTL = capTTL >= kCapStableTime ? null : capTTL;
    }

    if (capTTL != null) {
      loadBalance = 0;
    } else {
      var c = 2 * capacitorCapacity / tau;
      var k = totalPositiveCapNeeded / c;
      var fourK = min(1, 4 * k);
      var exponent = (1 - sqrt(1 - fourK)) / 2;

      if (exponent == 0) {
        loadBalance = 1;
      } else {
        var t = -log(exponent) * tau;
        loadBalance = pow(1 - exp(-t / tau), 2) as double;
      }
    }

    // if its NULL its stable
    capTTL ??= kCapStableTime;

    return CapacitorSimulationResults(
      capacity: capacitorCapacity,
      rechargeTimeMs: rechargeTime,
      rechargeRate: rechargeRateAverage,
      ttl: Duration(milliseconds: capTTL.toInt()),
      peakRechargeRate: peakRechargeRate,
      loadBalance: loadBalance,
      totalCapacitorNeeded: totalCapNeed,
    );
  }

  double runCapacitorSimulation(double capacity, double rechargeRate,
      List<ModuleCapacitorData> modulesData) {
    var capacitor = capacity;
    var tau = (rechargeRate / 5.0);
    var currentTime = 0.0;
    var nextTimeStep = 0.0;

    while (capacitor > 0.0 && nextTimeStep < kCapStableTime) {
      capacitor = pow(
              1.0 +
                  (sqrt(capacitor / capacity) - 1.0) *
                      exp((currentTime - nextTimeStep) / tau),
              2) *
          capacity;
      currentTime = nextTimeStep;
      nextTimeStep = kCapStableTime;

      for (var data in modulesData) {
        if (data.nextRun == currentTime) {
          capacitor -= data.capNeeded;
          data.cyclesSinceReload += 1;

          if (data.reactivationDelay > 0.0) {
            data.nextRun += data.reactivationDelay;
          }

          data.nextRun += data.durationValue;
        }
        nextTimeStep = min(nextTimeStep, data.nextRun);
      }
    }

    return capacitor > 0.0 ? kCapStableTime : currentTime;
  }
}

class ModuleCapacitorData {
  final double capNeeded;
  final double durationValue;
  final double reactivationDelay;
  //reloadInfo?
  double nextRun = 0;
  double cyclesSinceReload = 0;

  ModuleCapacitorData(
      {required this.capNeeded,
      required this.durationValue,
      required this.reactivationDelay});
}
