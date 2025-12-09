import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_presentation_universal/presentation/loyalty/widgets/loyalty_product_information_card/widgets/widgets.dart';
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';

import '../widgets.dart';

class PrivilegeResults extends StatelessWidget {
  final List<LoyaltyProgramProductSpec> data;
  const PrivilegeResults({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTapViewAll,
    required this.onTapCard,
    required this.isViewAll,
    required this.count,
  });

  final bool isSelected;
  final VoidCallback onTapViewAll;
  final Function(int) onTapCard;
  final bool isViewAll;
  final int count;
  @override
  Widget build(BuildContext context) {
    if (!isSelected && !isViewAll) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding7),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: kPadding7),
              child: ResultHeader(
                title: context.lang('bottom_navigation_privileges'),
                resultKey: 'privilege',
                resultCount: count,
                isShowViewAll: !isSelected && count > 10,
                onTapViewAll: onTapViewAll,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.only(bottom: kPadding6),
                  child: LoyaltyProductInformationCardWidget
                      .withLoyaltyProgramProductSpec(
                    context,
                    key: ValueKey(
                        'myaisCommonSearch/privilegeCard/$index/cardProductInformation'),
                    object: data[index],
                    onTapCard: (str) {},
                  ));
            }, childCount: isSelected ? data.length : data.take(10).length),
          ),
          if (!isSelected && count > 10)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: kPadding3),
                child: ViewAllTonalButton(
                  resultNumber: count,
                  title: context.lang('home_loyalty_link_view_all'),
                  onPressed: onTapViewAll,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(top: kPadding9))
        ],
      ),
    );
  }
}
