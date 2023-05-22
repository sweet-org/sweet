import 'package:flutter/material.dart';

class ItemDetailDescripton extends StatelessWidget {
  static const icon = Icons.description;
  static const label = 'Description';

  final String itemDescription;

  const ItemDetailDescripton({
    Key? key,
    required this.itemDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              itemDescription,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
