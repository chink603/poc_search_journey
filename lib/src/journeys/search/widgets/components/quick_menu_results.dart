import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class QuickMenuResults extends StatelessWidget {
  const QuickMenuResults({
    super.key,
    required this.isSelected,
    required this.onTapViewAll,
    required this.data,
    required this.onTapCard,
  });

  final bool isSelected;
  final VoidCallback onTapViewAll;
  final List<SearchQuickMenuModel> data;
  final Function(int index) onTapCard;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding7),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: ResultHeader(
              title: context.lang('edit_quick_menu_list'),
              resultKey: 'menu',
              resultCount: data.length,
              isShowViewAll: !isSelected && data.length > 4,
              onTapViewAll: onTapViewAll,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: kPadding4)),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0, // Horizontal gap between cards
              childAspectRatio: 0.8,
            ),
            itemCount: isSelected ? data.length : data.take(4).length,
            itemBuilder: (context, index) {
              return MyaQuickMenuPrimaryItem(
                key: ValueKey(
                    'myaisCommonSearch/menu/${MyaQuickMenuPrimaryItem.compType}/$index'),
                height: 88,
                labelText: context.lang(data[index].name),
                iconKey: data[index].img,
                labelBadge: data[index].isNew ? 'New' : '',
                onPressed: () => onTapCard(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
