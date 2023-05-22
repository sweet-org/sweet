import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/character/learned_skill.dart';
import 'package:sweet/model/fitting/fitting_ship.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/model/items/skills.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/util/constants.dart';

import 'mock_platform_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Ensure Nurf Denominators are correct', () {
    var expected = [
      1.0,
      0.869201150346033,
      0.5707963267948966,
      0.2831930766489234,
      0.10615114392969364,
      0.030061269039252634,
      0.0064317703161929345,
      0.0010396671655238492
    ];

    for (var i = 0; i < kNurfDenominators.length; i++) {
      expect(kNurfDenominators[i], expected[i]);
    }
  });

  group('Data tests >', () {
    var itemRepo = ItemRepository();
    var attrCalc = AttributeCalculatorService(itemRepository: itemRepo);

    setUpAll(() async {
      // Load item repo
      print('Loading files');
      PathProviderPlatform.instance = MockPathProviderPlatform();
      SharedPreferences.setMockInitialValues({}); //set values here
      return itemRepo.openDatabase();
    });

    group('Individual Items', () {
      test('Mk.VII Armored Command Burst', () async {
        final module = await itemRepo.module(id: 11125100008);
        final skills = await itemRepo.fittingSkillsFromLearned([
          LearnedSkill(skillId: 49340000013, skillLevel: 5),
        ]);

        final armorBaseValue = attrCalc.getValueForItemWithAttributeId(
            attributeId: 1506, item: module);
        expect(armorBaseValue, 0.0731);

        await attrCalc.setup(
          skills: skills.toList(),
          ship: FittingShip.empty,
        );

        final armorLv5Value = attrCalc.getValueForItemWithAttributeId(
            attributeId: 1506, item: module);
        expect(armorLv5Value.toStringAsFixed(5), '0.08772');
      });

      test(
        'Mk9 Drone Damage Amp',
        () async {
          print(DateTime.now());
          final module = await itemRepo.module(id: 11519000010);
          print(DateTime.now());
          final skills = await itemRepo.fittingSkillsFromDbSkills();

          final armorBaseValue = attrCalc.getValueForItemWithAttributeId(
              attributeId: 430, item: module);
          expect(armorBaseValue, 20000);

          print(DateTime.now());
          await attrCalc.setup(
            skills: skills.toList(),
            ship: FittingShip.empty,
          );

          print(DateTime.now());
          final armorLv5Value = attrCalc.getValueForItemWithAttributeId(
              attributeId: 430, item: module);
          expect(armorLv5Value, 44000);
        },
        skip:
            'This should only be run manually for now until someone minimises the number of skills loaded',
      );

      test('Freq Reducing 3P Engineering Integrator', () async {
        final rigIntegrator = await itemRepo.rigIntegrator(id: 11721010002);

        final dynamicValveRig = await itemRepo.module(id: 11710000006);
        final auxilaryThrusterRig = await itemRepo.module(id: 11710010006);
        final polycarbHousingRig = await itemRepo.module(id: 11710020006);

        var canFit = rigIntegrator.canFit(rig: dynamicValveRig);
        expect(canFit, true, reason: 'Expect to fit Dynamic Valve rig');

        canFit = rigIntegrator.canFit(rig: auxilaryThrusterRig);
        expect(canFit, true, reason: 'Expect to fit Auxiliary Thrusters rig');

        canFit = rigIntegrator.canFit(rig: polycarbHousingRig);
        expect(canFit, true,
            reason: 'Expect to fit Polycarb Engine Housing rig');

        rigIntegrator.fit(rig: dynamicValveRig, index: 0);
        rigIntegrator.fit(rig: auxilaryThrusterRig, index: 1);
        rigIntegrator.fit(rig: polycarbHousingRig, index: 2);

        final capNeedAdj = dynamicValveRig.modifiers.firstWhere(
          (m) =>
              m.attributeId ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );
        expect(capNeedAdj.attributeValue, -0.4);

        final rigCapNeedAdj = rigIntegrator.modifiers.firstWhere(
          (m) =>
              m.attributeId ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );

        expect(
          rigCapNeedAdj.attributeValue,
          -0.24,
        );

        final rigCapNeedAdjAttribute = rigIntegrator.baseAttributes.firstWhere(
          (attr) =>
              attr.id ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );

        expect(
          rigCapNeedAdjAttribute.baseValue,
          -0.24,
        );

        // await attrCalc.setup(
        //   skills: [],
        //   ship: FittingShip.empty,
        // );
      });
    });

    group('Ship Mode Tests', () {
      test('Max Velocity (Bomber)', () async {
        var ship = await itemRepo.ship(
          id: 10100000322,
        );

        final fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        fitting.setShipMode(enabled: false);
        await fitting.updateSkills();

        final velocity = fitting.maxFlightVelocity();
        expect(velocity, 363.0);

        fitting.setShipMode(enabled: true);

        await fitting.updateSkills();

        final modified = fitting.maxFlightVelocity();
        expect(modified.toStringAsFixed(2), '18.15');
      });

      test('Max Velocity (Dread)', () async {
        var ship = await itemRepo.ship(
          id: 10701000101,
        );

        final fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        fitting.setShipMode(enabled: false);
        await fitting.updateSkills();

        final velocity = fitting.maxFlightVelocity();
        expect(velocity, 83.0);

        fitting.setShipMode(enabled: true);

        await fitting.updateSkills();

        final modified = fitting.maxFlightVelocity();
        expect(modified.toStringAsFixed(2), '0.00');
      });
    });

    group('Drone Tests', () {
      test('MK5 Hammerhead', () async {
        var drone = await itemRepo.drone(
          id: 14000120006,
          attributeCalculatorService: attrCalc,
        );

        await drone.fitting.updateSkills();

        var droneDps = drone.fitting.calculateTotalDps();

        expect(
          droneDps.toStringAsFixed(2),
          '20.27',
        );

        var charData =
            'QlpoOTFBWSZTWdnh5wQABlRfgDAAUAZ/8AAkCAo/b50qQAH9lEadhlQAMhpoAANNANMRCKGnpqHlBkAAGnqUARgmIDIZGjAiSmgRpMgyBoZAZMFRP7218ePIUIqJEB/OB07CKiRURwGuu3bsyZPchxFMOyEm1pQZdLbSpvLtNmi0iU2WTezdU6pCpwklvduKwF/CIEDXIekVEsPflcKiXZ3Vs0koqBJIhV2q8tJKIIKCBQJIUFUQiSWCQpSaISmpLfHeiSBBIjcRLsBwQQQBDeNMiW5SaBavGkAeCQBiAsTmATAxec6nKumZTNTJc5xmYMCOWnPLAs1VatlrSWkKoyHZyzBDTsBkwHAR3QvEALF8y7cQwA0lQDEcTCWLBWJaVEJctFQpqyCGMFv1c96Ap5iohz3RF8yG4B1T62bkkEWJW21UnxJBHRJBCVyM8Kon0KiVn3KiQVEv3AClbb7ddvW/C8VE32zVE18Pt6RQTw90kkkkCRk8qpJ3ScEwMMDAwCdwWjvAwCQgEeoPvxdyRThQkNnh5wQ=';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        await drone.fitting.updateSkills(skills: skills);

        droneDps = drone.fitting.calculateTotalDps();

        expect(
          droneDps.toStringAsFixed(2),
          '26.56',
        );
      });

      test('Heavy Dust Salvage Drone', () async {
        var drone = await itemRepo.drone(
          id: 14504000012,
          attributeCalculatorService: attrCalc,
        );

        await drone.fitting.updateSkills();

        var droneDps = drone.fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          index: 0,
          slot: SlotType.high,
        );

        expect(
          droneDps.toStringAsFixed(2),
          '16000.00',
        );

        var charData =
            'QlpoOTFBWSZTWcoGNHEABuHfgHAAEAZ/8AAsCAo/L58qQAIdbdmAhFMTaZQANNAAAAlT2pEm1QAA9QAAaET9FU0DQaDRoBhNMgIlEaTE1T01PAp6jTaR+qbTSWFU6bN/b8+wqUFUgA6979PMIKpBV4JBQcLnUNWpog5LF1uIUEBCZGCmMA0EYpWILUR410xjQm6qTXdpMFOcDjXFVV73uXvm7fK5d2N6KnCvfFVTYPegKpQc88s7i66taSsKSklIAgCCBwKThJpMhNMIGNwgBiLt6bxlJEOixYMobBIGrsW0B1IxyrSlKpJMyEVWMVdg0Lc1i3fBCzbJMsTIxylpUpShcQmxU4TQccEwTCSSbCBZAs2CwRhjTEvFLxVOEELgtJG1hLIF4rcXp6bt+69vjJCTP8VSpJJx4Va7RQ94AuH3AAeYqkgqnn59Ovzu8b+e3SvH2+3x7iqc8+njr15dOYqmoqmPbT+Iql2vPUFU/3IVTaiqbPPFFUryur2/X19WwwBVO2hptFUz/fhfMFE1e8+GlApNalaQo1JSQZKpJTLQKglQpJKPuF4SMooGQhGkom//F3JFOFCQygY0cQ==';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        await drone.fitting.updateSkills(skills: skills);

        droneDps = drone.fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          index: 0,
          slot: SlotType.high,
        );

        expect(
          droneDps.toStringAsFixed(2),
          '19840.00',
        );
      });
    });

    ///
    /// These tests will create a Fitting consisting of:
    /// Ship: Caracal 10300000108
    /// High Slot: 1x 'Challenger Medium Torpedo Launcher 11017000012
    /// Low Slot: 2x Full Duplext BCS 11516000012
    /// Rig: 1x Loading Accelerator Prototype 11706050001
    ///
    /// Skills:                               IDs
    /// - Med Missile Operation: Lv 4     49440000007
    /// - Adv Med Missile Operation: Lv 4 49440000008
    /// - Med Missile Upgrade: Lv 4       49440000010
    /// - Adv Med Missile Upgrade: Lv 3   49440000011
    /// - Crusier Comand: Lv 4            49110000007
    ///
    /// Expected Activation time (Attr 430):  ~4.98 seconds
    group('Caracal fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000108);
        expect(ship, isNotNull, reason: 'Cannot find Caracal item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var skills = [
          LearnedSkill(
            skillId: Skills.CruiserCommand,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.MediumMissileTorpedoOperation,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.AdvancedMediumMissileTorpedoOperation,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.MediumMissileTorpedoUpgrade,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.AdvancedMediumMissileTorpedoUpgrade,
            skillLevel: 3,
          ),
        ];

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var torpedo = await itemRepo.module(id: 11017000012);
        expect(
          torpedo,
          isNotNull,
          reason: 'Cannot find Challenger Medium Torpedo Launcher item',
        );

        var bcs = await itemRepo.module(id: 11516000012);
        expect(
          bcs,
          isNotNull,
          reason: 'Cannot find Full Duplex BCU item',
        );

        var loadingRig = await itemRepo.module(id: 11706050001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Loading Rig item',
        );

        var heatingRig = await itemRepo.module(id: 11706010001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Warhead Heating Catalyst Prototype item',
        );

        fitting.fitItem(torpedo, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 1, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 2, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 3, notify: false);

        fitting.fitItem(
          bcs,
          slot: SlotType.low,
          index: 0,
          notify: false,
          state: ModuleState.inactive,
        );
        fitting.fitItem(
          bcs,
          slot: SlotType.low,
          index: 1,
          notify: false,
          state: ModuleState.inactive,
        );

        fitting.fitItem(loadingRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(heatingRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      group('Challenge Med Torpedo >', () {
        test('Activation Time is 4.85s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);

          expect(attributeDefinition, isNotNull);

          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '4.85',
          );
        });

        test('Calc DPS is 107.97', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '107.97',
          );
        });

        test('Damages are 131.02', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            3.743557512292552,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(2),
            '131.02',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(2),
            '131.02',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(2),
            '131.02',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(2),
            '131.02',
          );
        });
      });
    });

    group('Stabber fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000208);
        expect(ship, isNotNull, reason: 'Cannot find Stabber item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var charData =
            'QlpoOTFBWSZTWdnh5wQABlRfgDAAUAZ/8AAkCAo/b50qQAH9lEadhlQAMhpoAANNANMRCKGnpqHlBkAAGnqUARgmIDIZGjAiSmgRpMgyBoZAZMFRP7218ePIUIqJEB/OB07CKiRURwGuu3bsyZPchxFMOyEm1pQZdLbSpvLtNmi0iU2WTezdU6pCpwklvduKwF/CIEDXIekVEsPflcKiXZ3Vs0koqBJIhV2q8tJKIIKCBQJIUFUQiSWCQpSaISmpLfHeiSBBIjcRLsBwQQQBDeNMiW5SaBavGkAeCQBiAsTmATAxec6nKumZTNTJc5xmYMCOWnPLAs1VatlrSWkKoyHZyzBDTsBkwHAR3QvEALF8y7cQwA0lQDEcTCWLBWJaVEJctFQpqyCGMFv1c96Ap5iohz3RF8yG4B1T62bkkEWJW21UnxJBHRJBCVyM8Kon0KiVn3KiQVEv3AClbb7ddvW/C8VE32zVE18Pt6RQTw90kkkkCRk8qpJ3ScEwMMDAwCdwWjvAwCQgEeoPvxdyRThQkNnh5wQ=';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              (await itemRepo.getShipLoadoutDefinition(ship.itemId))),
        );

        var weapon = await itemRepo.module(id: 11004610024);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Gistum C-Type Med Strike Cannon',
        );

        var trackingComp = await itemRepo.module(id: 11322000012);
        expect(
          trackingComp,
          isNotNull,
          reason: 'Cannot find Marketeer tracking comp',
        );

        var gyro = await itemRepo.module(id: 11501000021);
        expect(
          gyro,
          isNotNull,
          reason: 'Cannot find Rebirth gyro',
        );

        var loadingRig = await itemRepo.module(id: 11704000002);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Loading Rig item',
        );

        var heatingRig = await itemRepo.module(id: 11704020002);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Warhead Heating Catalyst Prototype item',
        );

        var pgRig = await itemRepo.module(id: 11711020001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Auxiliary Energy Router Prototype item',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 1, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 2, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 3, notify: false);

        fitting.fitItem(trackingComp,
            slot: SlotType.low, index: 0, notify: false);
        // fittut.fitItem(trackingComp, slot: SlotType.low, index: 1, notify: false);
        fitting.fitItem(gyro, slot: SlotType.low, index: 2, notify: false);
        fitting.fitItem(gyro, slot: SlotType.low, index: 3, notify: false);

        fitting.fitItem(loadingRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(heatingRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        fitting.fitItem(pgRig,
            slot: SlotType.engineeringRig, index: 0, notify: false);

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 2,
        );
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 3,
        );

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Powergrid Usage', () async {
        var powerGrid = fitting.calculatePowerGridUtilisation();

        expect(
          (powerGrid * 100).toStringAsFixed(2),
          '98.36',
        );
      });

      test('Flight Velocity is 372.06', () async {
        var speed = fitting.getValueForItem(
          attribute: EveEchoesAttribute.flightVelocity,
          item: fitting.ship,
        );

        expect(
          speed.toStringAsFixed(2),
          '372.06',
        );
      });

      group('Gistum C-Type Med Strike Cannon >', () {
        test('Activation Time is 7.99s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          expect(attributeDefinition, isNotNull);
          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '7.99',
          );
        });

        test('Calc DPS is 82.97', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '82.97',
          );
        });

        test('Damages are correct 0/247/168/247', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            9.890154399064471,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(0),
            '0',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(0),
            '247',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(0),
            '168',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(0),
            '247',
          );
        });
      });
    });

    group('Kryos fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10600000401);
        expect(ship, isNotNull, reason: 'Cannot find Kryos item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var skills = [
          LearnedSkill(skillId: 49110000016, skillLevel: 4),
          LearnedSkill(skillId: 49110000017, skillLevel: 3),
        ];

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var cargoHoldRig = await itemRepo.module(id: 11710010001);
        expect(
          cargoHoldRig,
          isNotNull,
          reason: 'Cannot find cargo Hold Rig item',
        );

        fitting.fitItem(cargoHoldRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(cargoHoldRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Cargo hold is 3,600m3', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.cargoHoldCapacity.attributeId);
        var value = fitting.getValueForItem(
          item: fitting.ship,
          attribute: EveEchoesAttribute.cargoHoldCapacity,
        );

        expect(attributeDefinition, isNotNull);
        value = attributeDefinition!.calculatedValue(fromValue: value);

        expect(
          value,
          3600,
        );
      });

      test('Mineral hold is 46,000m3', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.mineralHoldCapacity.attributeId);
        var value = fitting.getValueForItem(
          item: fitting.ship,
          attribute: EveEchoesAttribute.mineralHoldCapacity,
        );

        expect(attributeDefinition, isNotNull);
        value = attributeDefinition!.calculatedValue(fromValue: value);

        expect(
          value,
          46000,
        );
      });

      test('Defence EHP is ~7182', () async {
        var value = fitting.calculateWeakestEHP();
        expect(
          value.toStringAsFixed(2),
          '7182.34',
        );
      });
    });

    group('Atron fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.FrigateCommand, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedFrigateCommand, skillLevel: 4),
        LearnedSkill(skillId: Skills.Afterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedAfterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.ShieldOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedShieldOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.FrigateEngineering, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedFrigateEngineering, skillLevel: 3),
        LearnedSkill(skillId: Skills.ElectronicWarfare, skillLevel: 4),
        LearnedSkill(skillId: Skills.SignalDisruption, skillLevel: 3),
        LearnedSkill(skillId: Skills.SmallRailgunOperation, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.SmallRailgunUpgrade, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000405);
        expect(ship, isNotNull, reason: 'Cannot find Atron item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000520021);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Quafe Small Snubnosed Railgun',
        );

        var scram = await itemRepo.module(id: 11347000006);
        expect(
          scram,
          isNotNull,
          reason: 'Cannot find Mk5 Warp Scrambler',
        );

        var shieldBooster = await itemRepo.module(id: 11302000012);
        expect(
          shieldBooster,
          isNotNull,
          reason: 'Cannot find Settler Small Shield Booster',
        );

        var afterBurner = await itemRepo.module(id: 11304500012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Smuggler Small Afterburner gyro',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 1, notify: false);

        fitting.fitItem(scram, slot: SlotType.mid, index: 0, notify: false);

        fitting.fitItem(shieldBooster,
            slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(afterBurner,
            slot: SlotType.low, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Afterburner activation time is 8.836s', () {
        // Damage mod
        var value = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.activationTime,
          slot: SlotType.low,
          index: 1,
        );

        expect(value, 8836);
      });

      test('Shield booster activation cost is 29.58', () {
        // Damage mod
        var value = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.activationCost,
          slot: SlotType.low,
          index: 0,
        );

        expect(value.toStringAsFixed(2), '29.58');
      });

      test('Capacitor lasts 1m 07 secs', () async {
        var value = await fitting.capacitorSimulation();
        expect(
          value.ttl.inSeconds,
          67,
        );
      });

      test('Mag Stab Unfit/Cold/Hot', () async {
        var magStab = await itemRepo.module(id: 11510000012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '119.57');

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        // Not needed in app running, but need to wait for testing
        await fitting.updateSkills(skills: skills);
        dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '158.07');

        fitting.setModuleState(ModuleState.inactive,
            slot: SlotType.low, index: 0);
        // Not needed in app running, but need to wait for testing
        await fitting.updateSkills(skills: skills);
        dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '140.20');
      });
    });
    group('Thorax fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.CruiserCommand, skillLevel: 4),
        LearnedSkill(skillId: Skills.CruiserEngineering, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedCruiserEngineering, skillLevel: 4),
        //
        LearnedSkill(skillId: Skills.Afterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedAfterburner, skillLevel: 4),
        //
        LearnedSkill(skillId: Skills.ArmorOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedArmorOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.ArmorHardening, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedArmorHardening, skillLevel: 3),
        //
        LearnedSkill(skillId: Skills.MediumRailgunOperation, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedMediumRailgunOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.MediumRailgunUpgrade, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedMediumRailgunUpgrade, skillLevel: 3),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000410);
        expect(ship, isNotNull, reason: 'Cannot find Thorax item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000620013);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Fed Navy Medium Snubnosed Railgun',
        );

        var scram = await itemRepo.module(id: 11347000012);
        expect(
          scram,
          isNotNull,
          reason: 'Cannot find Interuptive Warp Scrambler',
        );

        var nos = await itemRepo.module(id: 11031100012);
        expect(
          nos,
          isNotNull,
          reason: 'Cannot find Upir Med Nos',
        );

        var magStab = await itemRepo.module(id: 11510000012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var armHard = await itemRepo.module(id: 11513100012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var afterBurner = await itemRepo.module(id: 11304600012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Smuggler Med Afterburner gyro',
        );

        var armRep = await itemRepo.module(id: 11503100012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Gorget Med Arm Rep',
        );

        var burstRig = await itemRepo.module(id: 11700030002);
        expect(
          burstRig,
          isNotNull,
          reason: 'Cannot find Railgun Burst Aerator I item',
        );

        fitting.fitItemIntoAll(weapon, slot: SlotType.high, notify: false);

        fitting.fitItem(scram, slot: SlotType.mid, index: 0, notify: false);
        fitting.fitItem(nos, slot: SlotType.mid, index: 1, notify: false);

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(magStab, slot: SlotType.low, index: 1, notify: false);

        fitting.fitItem(armHard, slot: SlotType.low, index: 2, notify: false);
        fitting.fitItem(armRep, slot: SlotType.low, index: 3, notify: false);
        fitting.fitItem(afterBurner,
            slot: SlotType.low, index: 4, notify: false);

        fitting.fitItem(burstRig, slot: SlotType.combatRig, index: 0);
        fitting.fitItem(burstRig, slot: SlotType.combatRig, index: 1);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });
      group('Fed Nav Med Snub Rails >', () {
        test('Activation Time is 2.81s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          expect(attributeDefinition, isNotNull);
          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '2.81',
          );
        });

        test('Calc DPS is 152', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '152.14',
          );
        });

        test('Damages are 0/162/265/0', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            7.373324435311049,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(2),
            '0.00',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(2),
            '162.21',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(2),
            '265.44',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(2),
            '0.00',
          );
        });
      });

      test('Capacitor lasts 328s', () async {
        var value = await fitting.capacitorSimulation();
        expect(
          value.ttl.inSeconds,
          328,
        );
      });
    });

    group('Executioner fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.SmallRailgunOperation, skillLevel: 5),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.SmallRailgunUpgrade, skillLevel: 5),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunUpgrade, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000309);
        expect(ship, isNotNull, reason: 'Cannot find Executioner item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000020008);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Mk7 Small Rifled Railgun',
        );

        var magStab = await itemRepo.module(id: 11510000010);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Mk9 Magnetic Field Stabilizer',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(magStab, slot: SlotType.low, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      // test('Both Weapon Mods Inactive 35.39', () {
      //   fitting.setModuleState(
      //     ModuleState.inactive,
      //     slot: SlotType.low,
      //     index: 0,
      //   );

      //   fitting.setModuleState(
      //     ModuleState.inactive,
      //     slot: SlotType.low,
      //     index: 1,
      //   );

      //   final value = fitting.calculateTotalDps();

      //   expect(value.toStringAsFixed(2), '35.39');
      // });

      test('Both Weapon Mods Active 55.05', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 1,
        );

        // Damage mod
        final value = fitting.calculateTotalDps();

        expect(
          value.toStringAsFixed(2),
          '55.05',
        );
      });

      test('Only 1 Weapon Mod active 49.86 (slot 2)', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '49.86');
      });

      test('Only 1 Weapon Mod active 49.86 (slot 1)', () {
        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '49.86');
      });

      test('Both Weapon Mods Inactive 44.41', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '44.41');
      });
    });

    group('Noctis fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: 49520000007, skillLevel: 3),
        LearnedSkill(
            skillId: Skills.ExpertIndustrialShipCommand, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10600001412);
        expect(ship, isNotNull, reason: 'Cannot find Noctis item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var salvager = await itemRepo.module(id: 11117010013);
        expect(
          salvager,
          isNotNull,
          reason: 'Cannot find Gallente Auto Salvager',
        );

        fitting.fitItem(salvager, slot: SlotType.mid, index: 0, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Gallente Auto Salvager Optimal Range is 32.55km', () async {
        // Extract final 'display' value for Activation Time attribute (ID: 430)
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.optimalRange.attributeId);

        final salvagerRange = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          slot: SlotType.mid,
          index: 0,
        );

        final value =
            attributeDefinition?.calculatedValue(fromValue: salvagerRange) ?? 0;

        expect(value.toStringAsFixed(2), '32.55');
      });
    });
  });
}
