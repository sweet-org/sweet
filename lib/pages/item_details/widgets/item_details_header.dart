import 'package:sweet/database/entities/item.dart';
import 'package:flutter/material.dart';
import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/widgets/localised_text.dart';

class ItemDetailsHeader extends StatelessWidget {
  final Item item;

  const ItemDetailsHeader({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Spacer(),
                          SizedBox.fromSize(
                            size: Size.square(72),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    LocalisedText(
                      item: item,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                    PlatformHelper.isDebug
                        ? Text(
                            'ID: ${item.id}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(96),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.end,
                          )
                        : Container()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
