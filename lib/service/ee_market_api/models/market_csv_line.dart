class EEMarketItem {
  final int itemId;
  final DateTime time;
  final double price;


  static EEMarketItem get zero => EEMarketItem(
        itemId: 0,
        time: DateTime.now(),
        price: 0,
      );

  EEMarketItem({
    required this.itemId,
    required this.time,
    required this.price,
  });
}
