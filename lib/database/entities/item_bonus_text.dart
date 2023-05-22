

class ItemBonusText {
  final int id;
  final int localisedTextId;

  ItemBonusText({required this.id, required this.localisedTextId});

  factory ItemBonusText.fromJson(Map<String, dynamic> json) => ItemBonusText(
        id: json['id'],
        localisedTextId: json['localisedTextId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'localisedTextId': localisedTextId,
      };
}
