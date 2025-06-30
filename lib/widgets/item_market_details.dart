import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:sweet/service/ee_market_api/ee_market_api_service.dart';

final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

class ItemMarketDetails extends StatelessWidget {
  final int itemId;

  const ItemMarketDetails({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final market = RepositoryProvider.of<EEMarketApiService>(context);

    final marketDetails = market.marketDataForItem(itemId: itemId);
    final formatter = NumberFormat.compact();
    final price = formatter.format(marketDetails.price);
    final time = _dateFormat.format(marketDetails.time);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
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
                  Text('Estimated market price: '),
                  Text('$price ISK'),
                ],
              ),
            ),
            Text('Time of data: $time')
          ],
        ),
      ),
    );
  }
}
