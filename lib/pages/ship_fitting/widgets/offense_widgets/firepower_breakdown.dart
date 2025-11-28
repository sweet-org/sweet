import 'package:flutter/material.dart';
import 'package:sweet/pages/ship_fitting/widgets/mining_yeild.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';
import '../../../../model/ship/weapon_type.dart';
import 'weapon_type_damage_widget.dart';

class FirepowerBreakdown extends StatefulWidget {
  final bool condensed;

  const FirepowerBreakdown({
    super.key,
    this.condensed = false,
  });

  @override
  State<FirepowerBreakdown> createState() => _FirepowerBreakdownState();
}

class _FirepowerBreakdownState extends State<FirepowerBreakdown> {
  final double condensedIconSize = 32;
  final double iconSize = 64;
  var _showMining = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _showMining = !_showMining),
                child: Image.asset(
                  _showMining
                      ? 'assets/icons/icon-turret.png'
                      : 'assets/icons/mining-laser.png',
                  height: 20,
                ),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: _showMining ? _buildMining() : _buildFirepower(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirepower() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: widget.condensed ? condensedIconSize : iconSize,
                ),
                LocalisedText(localiseId: LocalisationStrings.dps),
                Text('Alpha'),
              ],
            ),
          ),
          Container(
            child: WeaponTypeDamageWidget(
              weaponType: WeaponType.turret,
              iconSize: widget.condensed ? condensedIconSize : iconSize,
            ),
          ),
          Container(
            child: WeaponTypeDamageWidget(
              weaponType: WeaponType.missile,
              iconSize: widget.condensed ? condensedIconSize : iconSize,
            ),
          ),
          Container(
            child: WeaponTypeDamageWidget(
              weaponType: WeaponType.drone,
              iconSize: widget.condensed ? condensedIconSize : iconSize,
            ),
          ),
          Container(
            child: WeaponTypeDamageWidget(
              weaponType: WeaponType.all,
              iconSize: widget.condensed ? condensedIconSize : iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Row _buildMining() {
    return Row(
      children: [
        Expanded(
          child: MiningYeild(
            type: YeildTypes.turret,
          ),
        ),
        Expanded(
          child: MiningYeild(
            type: YeildTypes.drones,
          ),
        ),
        Expanded(
          child: MiningYeild(
            type: YeildTypes.timeToFill,
          ),
        ),
      ],
    );
  }
}
