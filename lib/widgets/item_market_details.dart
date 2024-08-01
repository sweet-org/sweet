import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:sweet/service/ee_market_api/ee_market_api_service.dart';
import 'package:sweet/util/localisation_constants.dart';

import 'localised_text.dart';

class ItemMarketDetails extends StatelessWidget {
  final int itemId;

  const ItemMarketDetails({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final market = RepositoryProvider.of<EEMarketApiService>(context);

    final marketDetails = market.marketDataForItem(itemId: itemId);
    final formatter = NumberFormat.compact();
    final price = formatter.format(marketDetails.price);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text('${StaticLocalisationStrings.sell}: '),
                  Text('$price ISK'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
