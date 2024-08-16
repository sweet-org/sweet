import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/mixins/fitting_item_details_mixin.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';


import 'package:sweet/pages/ship_fitting/widgets/module_state_toggle.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

typedef FittingModuleTileTapCallback = void Function(int index);
typedef ModuleCloneCallback = void Function(int index);

class ImplantModuleTile extends StatelessWidget with FittingItemDetailsMixin {
  final int index;
  final FittingImplantModule module;
  final FittingModuleTileTapCallback onTap;
  final VoidCallback onClearPressed;
  final ModuleCloneCallback onClonePressed;
  final ModuleStateToggleCallback onStateToggle;

  const ImplantModuleTile({
    Key? key,
    required this.index,
    required this.module,
    required this.onTap,
    required this.onClearPressed,
    required this.onClonePressed,
    required this.onStateToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onTap(index),
        child: _buildContent(context: context),
      );

  Widget _buildContent({required BuildContext context}) {
    if (!module.isValid) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: (AutoSizeText(StaticLocalisationStrings.emptyModule)),
        ),
      );
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: LocalisedText(
                item: module.item,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(
                Icons.info,
              ),
              onPressed: () => showItemDetails(
                module: module,
                itemRepository: RepositoryProvider.of<ItemRepository>(context),
                context: context,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(Icons.copy),
              onPressed: () => onClonePressed(index),
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(Icons.delete),
              onPressed: onClearPressed,
            ),
          ],
        ),
      )
    ]);
  }
}
