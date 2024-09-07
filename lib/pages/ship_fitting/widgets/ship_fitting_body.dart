import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/market_group.dart';
import 'package:sweet/mixins/fitting_item_details_mixin.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/pages/ship_fitting/widgets/nanocore_affix_context_drawer.dart';
import 'package:sweet/pages/ship_fitting/widgets/offense_widgets/damage_pattern_row.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/pages/ship_fitting/widgets/pilot_context_drawer.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_context_drawer.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_stats_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/util/localisation_constants.dart';

import 'implant_context_drawer.dart';
import 'ship_fitting_detail_panel.dart';
import 'ship_fitting_toolbar.dart';
import 'ship_mode_toggle.dart';
import 'ship_slot_list_view.dart';

class ShipFittingBody extends StatefulWidget {
  @override
  State<ShipFittingBody> createState() => _ShipFittingBodyState();
}

class _ShipFittingBodyState extends State<ShipFittingBody>
    with FittingItemDetailsMixin {
  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);
    return BlocListener<ShipFittingBloc, ShipFittingState>(
      listener: (context, state) {
        _handleFittingState(state, context);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return _buildWideLayout(fitting, context);
        } else {
          return _buildNarrowLayout(fitting, context);
        }
      }),
    );
  }

  Future<void> _handleFittingState(
      ShipFittingState state, BuildContext context) async {
    if (state is OpenContextDrawerState) {
      final selectedItem = await showMarketGroupDrawer(
          context, state.topGroup, state.initialItems, null);

      await _handleDrawerSelection(
        selectedItem,
        state.slotType,
        state.slotIndex,
      );
    }
    if (state is OpenRigIntegratorDrawer) {
      final selectedItem = await showMarketGroupDrawer(
          context, state.topGroup, state.initialItems, state.blacklistItems);

      if (selectedItem != null) {
        await _handleRigIntegratorSelection(
          rigIntegrator: state.rigIntegrator,
          item: selectedItem,
          index: state.slotIndex,
        );
      }
    }
    if (state is OpenNanocoreAffixDrawer) {
      final selectedAffix = await showGoldLibraryDrawer(
          context, state.topClasses, state.initialItems, []);

      await _handleNanocoreAffixSelection(selectedAffix, state.slotIndex);
    }

    if (state is OpenPilotDrawerState) {
      await showPilotDrawer(context, state);
    }

    if (state is OpenImplantDrawer) {
      await showImplantDrawer(context, state);
    }

    if (state is OpenFittingStatsDrawerState) {
      await showFittingStatsDrawer(context, state.fitting);
    }

    if (state is OpenDamagePatternDrawerState) {
      await showDamagePatternDrawer(context, state);
    }
  }

  Widget _buildWideLayout(FittingSimulator fitting, BuildContext context) =>
      Row(
        children: [
          Expanded(
            child: Column(
              verticalDirection: VerticalDirection.down,
              children: [
                ShipModeToggle(
                  shipMode: fitting.ship.shipMode,
                  onChanged: (switchOn) {
                    fitting.setShipMode(enabled: switchOn);
                  },
                  onInfoTapped: () => showItemDetails(
                    module: fitting.ship.shipMode ?? FittingModule.empty,
                    itemRepository:
                        RepositoryProvider.of<ItemRepository>(context),
                    context: context,
                  ),
                ),
                Expanded(
                  child: ShipSlotListView(
                    fitting: fitting,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ShipFittingDetailPanel(),
          ),
        ],
      );

  Widget _buildNarrowLayout(FittingSimulator fitting, BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.down,
      children: [
        ShipModeToggle(
          shipMode: fitting.ship.shipMode,
          onChanged: (switchOn) {
            fitting.setShipMode(enabled: switchOn);
          },
          onInfoTapped: () => showItemDetails(
            module: fitting.ship.shipMode ?? FittingModule.empty,
            itemRepository: RepositoryProvider.of<ItemRepository>(context),
            context: context,
          ),
        ),
        Expanded(
          child: ShipSlotListView(
            fitting: fitting,
          ),
        ),
        ShipFittingToolbar(),
      ],
    );
  }

  Future<void> showFittingStatsDrawer(
      BuildContext context, FittingSimulator fitting) async {
    await showModalBottomSheet(
      context: context,
      elevation: 16,
      builder: (context) => ShipFittingStatsDrawer(fitting: fitting),
    );
  }

  Future<void> showPilotDrawer(
      BuildContext context, OpenPilotDrawerState state) async {
    var selection = await showModalBottomSheet(
      context: context,
      elevation: 16,
      builder: (context) => PilotContextDrawer(),
    );

    if (selection != null) {
      state.fitting.setPilot(selection);
    }
  }

  Future<void> showImplantDrawer(
      BuildContext context, OpenImplantDrawer state) async {
    ImplantFittingLoadout? loadout = await showModalBottomSheet(
      context: context,
      elevation: 16,
      builder: (context) => ImplantContextDrawer(),
    );
    if (loadout == null) {
      state.fitting.setImplant(null);
      return;
    }
    final itemRepo = Provider.of<ItemRepository>(context, listen: false);

    final fitting = await ImplantHandler.fromImplantLoadout(
      implant: await itemRepo.implantModule(id: loadout.implantItemId),
      itemRepository: itemRepo,
      definition:
          await itemRepo.getImplantLoadoutDefinition(loadout.implantItemId),
      loadout: loadout,
    );

    state.fitting.setImplant(fitting);
  }

  Future<void> showDamagePatternDrawer(
      BuildContext context, OpenDamagePatternDrawerState state) async {
    var selection = await showModalBottomSheet(
      context: context,
      elevation: 16,
      builder: (context) => Container(
        height: 600,
        color: Theme.of(context).canvasColor,
        child: ListView.builder(
          itemCount: FittingSimulator.fittingPatterns.damage.length,
          itemBuilder: (context, index) {
            var pattern = FittingSimulator.fittingPatterns.damage[index];

            return Card(
              child: InkWell(
                onTap: () => Navigator.pop(context, pattern),
                child: DamagePatternRow(
                  rowHeight: 32,
                  damagePattern: pattern,
                  leading: AutoSizeText(
                    pattern.name,
                    textScaleFactor: 0.85,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (selection != null) {
      state.fitting.currentDamagePattern = selection;
    }
  }

  Future<Item?> showMarketGroupDrawer(
    BuildContext context,
    MarketGroup? topGroup,
    List<Item>? initialItems,
    List<int>? blacklistItems,
  ) async {
    return await showModalBottomSheet<Item>(
      context: context,
      elevation: 16,
      builder: (context) => ShipFittingContextDrawer(
        marketGroup: topGroup,
        initialFilteredItems: initialItems,
        blacklistItems: blacklistItems,
      ),
    );
  }

  Future<ItemNanocoreAffix?> showGoldLibraryDrawer(
    BuildContext context,
    List<GoldNanoAttrClass>? topClasses,
    List<ItemNanocoreAffix>? initialItems,
    List<int>? blacklistItems,
  ) async {
    return await showModalBottomSheet<ItemNanocoreAffix>(
      context: context,
      builder: (context) => NanocoreAffixContextDrawer(
        topClasses: topClasses,
        initialFilteredItems: initialItems,
        blacklistItems: blacklistItems,
      ),
    );
  }

  Future<void> _handleRigIntegratorSelection({
    required FittingRigIntegrator rigIntegrator,
    required Item item,
    required int index,
  }) async {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final fitting = Provider.of<FittingSimulator>(context, listen: false);
    final rig = await itemRepo.rig(id: item.id);

    if (!rigIntegrator.canFit(rig: rig)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StaticLocalisationStrings.cannotFitRig),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      rigIntegrator.fit(rig: rig, index: index);

      // Refit item to trigger the required paths
      fitting.fitItem(
        rigIntegrator,
        slot: rigIntegrator.slot,
        index: rigIntegrator.index,
      );

      await RepositoryProvider.of<ShipFittingLoadoutRepository>(context)
          .saveLoadouts();
    }
  }

  Future<void> _handleDrawerSelection(
    Item? item,
    SlotType slotType,
    int? slotIndex,
  ) async {
    if (item != null) {
      final fitting = Provider.of<FittingSimulator>(context, listen: false);
      final itemRepo = RepositoryProvider.of<ItemRepository>(context);
      final attrCalc =
          RepositoryProvider.of<AttributeCalculatorService>(context);

      final FittingModule module;
      switch (slotType) {
        case SlotType.lightFFSlot:
        case SlotType.lightDDSlot:
        case SlotType.drone:
          module = await itemRepo.drone(
            id: item.id,
            attributeCalculatorService: attrCalc,
          );
          break;

        case SlotType.nanocore:
          module = await itemRepo.nanocore(id: item.id);
          break;

        case SlotType.combatRig:
        case SlotType.engineeringRig:
          module = await itemRepo.rig(id: item.id);
          break;

        default:
          module = await itemRepo.module(id: item.id);
          break;
      }

      if (!fitting.canFitModule(module: module, slot: slotType)) {}

      if (slotIndex == null) {
        fitting.fitItemIntoAll(
          module,
          slot: slotType,
        );
      } else {
        final fitted = fitting.fitItem(
          module,
          slot: slotType,
          index: slotIndex,
        );

        if (!fitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(StaticLocalisationStrings.cannotFitModule),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      await RepositoryProvider.of<ShipFittingLoadoutRepository>(context)
          .saveLoadouts();
    }
  }

  Future<void> _handleNanocoreAffixSelection(
    ItemNanocoreAffix? item,
    int slotIndex,
  ) async {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final fitting = Provider.of<FittingSimulator>(context, listen: false);
    final affix =
        item == null ? null : await itemRepo.nanocoreAffix(affix: item);
    fitting.fitNanocoreAffix(affix, index: slotIndex);
    fitting.updateLoadout();
  }
}
