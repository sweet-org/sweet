import 'package:flutter/cupertino.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/pages/item_details/item_details_page.dart';
import 'package:sweet/repository/item_repository.dart';

mixin FittingItemDetailsMixin {
  Future<void> showItemDetails({
    required FittingItem module,
    required ItemRepository itemRepository,
    required BuildContext context,
  }) async {
    var item = await itemRepository.itemWithId(id: module.itemId);

    if (item != null) {
      await Navigator.pushNamed(
        context,
        ItemDetailsPage.routeName,
        arguments: item,
      );
    }
  }
}
