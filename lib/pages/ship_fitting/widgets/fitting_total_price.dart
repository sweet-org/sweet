import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/service/ee_market_api/ee_market_api_service.dart';

class FittingTotalPrice extends StatelessWidget {
  final ShipFittingLoadout fitting;

  const FittingTotalPrice({
    super.key,
    required this.fitting,
  });

  @override
  Widget build(BuildContext context) {
    final market = RepositoryProvider.of<EEMarketApiService>(context);

    final shipMarketDetails =
        market.marketDataForItem(itemId: fitting.shipItemId);
    final moduleDetails = fitting.allFittedItemIds
        .map((e) => MapEntry(e, market.marketDataForItem(itemId: e)));

    final totalModuleBuy = moduleDetails.fold<double>(
      0.0,
      (previousValue, element) => previousValue + element.value.price,
    );
    final totalPrice = shipMarketDetails.price + totalModuleBuy;

    NumberFormat formatter = NumberFormat.decimalPattern();

    final textSpan = TextSpan(
      text: '${formatter.format(shipMarketDetails.price)} '
          '${formatter.format(totalModuleBuy)} '
          '${formatter.format(totalPrice)}',
      style: TextStyle(color: Colors.white),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    if (tp.width + 32*6 > MediaQuery.of(context).size.width) {
      formatter = NumberFormat.compact();
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8.0,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/ships.png',
              width: 32,
              height: 32,
            ),
            Text(
              formatter.format(shipMarketDetails.price),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/itemhangar.png',
              width: 32,
              height: 32,
            ),
            Text(
              formatter.format(totalModuleBuy),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/wallet.png',
              width: 32,
              height: 32,
            ),
            Text(
              formatter.format(totalPrice),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
