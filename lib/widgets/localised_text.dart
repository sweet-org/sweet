import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/repository/localisation_repository.dart';

class LocalisedText extends StatelessWidget {
  final TextStyle? style;
  final Item? item;
  final int? localiseId;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String suffix;
  final bool autoSize;

  const LocalisedText({
    Key? key,
    this.style,
    this.item,
    this.localiseId,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.suffix = '',
    this.autoSize = false,
  })  : assert(
          !(item == null && localiseId == null),
          'Must give item or id!',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final localiseRepo = RepositoryProvider.of<LocalisationRepository>(context);
    final String text;

    if (localiseId != null) {
      text = localiseRepo.getLocalisedStringForIndex(localiseId);
    } else if (item != null) {
      text = localiseRepo.getLocalisedNameForItem(item as Item);
    } else {
      text = '';
    }

    return autoSize
        ? AutoSizeText(
            '$text$suffix',
            style: style,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          )
        : Text(
            '$text$suffix',
            style: style,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          );
  }
}
