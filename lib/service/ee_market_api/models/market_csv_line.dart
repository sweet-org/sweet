class EEMarketItem {
  final int itemId;
  final DateTime time;
  final double calculatedSell;
  final double calculatedBuy;
  final double lowestSell;
  final double highestBuy;

  static EEMarketItem get zero => EEMarketItem(
        itemId: 0,
        time: DateTime.now(),
        calculatedSell: 0,
        calculatedBuy: 0,
        lowestSell: 0,
        highestBuy: 0,
      );

  EEMarketItem({
    required this.itemId,
    required this.time,
    required this.calculatedSell,
    required this.calculatedBuy,
    required this.lowestSell,
    required this.highestBuy,
  });
}
