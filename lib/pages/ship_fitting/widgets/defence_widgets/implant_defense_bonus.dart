import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/sweet_icons.dart';

class ImplantDefenseBonusWidget extends StatefulWidget {
  const ImplantDefenseBonusWidget({
    super.key,
  });

  @override
  State<ImplantDefenseBonusWidget> createState() =>
      _ImplantDefenseBonusWidgetState();
}

class _ImplantDefenseBonusWidgetState extends State<ImplantDefenseBonusWidget> {
  @override
  Widget build(BuildContext context) {
    final fitting = RepositoryProvider.of<FittingSimulator>(context);
    final valShield =
        (fitting.getGlobalImplantShieldBonus() * 100).toStringAsFixed(2);
    final valArmor =
        (fitting.getGlobalImplantArmorBonus() * 100).toStringAsFixed(2);

    final baseText = TextSpan(
        text: 'Instabuff (${fitting.totalImplantLevels}x ');

    final Size size = (TextPainter(
        text: baseText,
        maxLines: 1,
        textScaler: MediaQuery.of(context).textScaler,
        textDirection: TextDirection.ltr)
      ..layout())
        .size;

    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              baseText,
              WidgetSpan(child: Icon(
                SweetIcons.implant,
                size: size.height - 3,
              )),
              TextSpan(text: ') '),
              WidgetSpan(
                child: Image.asset(
                  EveEchoesAttribute.shieldCapacity.iconName!,
                  height: size.height,
                ),
              ),
              TextSpan(text: '+$valShield % '),
              WidgetSpan(
                child: Image.asset(
                  EveEchoesAttribute.armorHp.iconName!,
                  height: size.height,
                ),
              ),
              TextSpan(text: '+$valArmor %'),
            ],
          ),
        ),
      ],
    );
  }
}
