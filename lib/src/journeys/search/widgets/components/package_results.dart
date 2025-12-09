import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_search_micro_journey/src/journeys/search/utils/util.dart';
import '../../models/models.dart';
import '../widgets.dart';
import 'package_search_card.dart';

class PackageResults extends StatelessWidget {
  const PackageResults({
    super.key,
    required this.isSelected,
    required this.data,
    required this.onTapViewAll,
    required this.onSelectPackageById,
    required this.onSelectBuyNow,
    required this.packageCards,
    required this.isViewAll,
  });

  final bool isSelected;
  final List<ProductOffering> data;
  final List<PackageCardViewModel> packageCards;
  final VoidCallback onTapViewAll;
  final Function(ProductOffering?) onSelectPackageById;
  final Function(String) onSelectBuyNow;
  final bool isViewAll;
  @override
  Widget build(BuildContext context) {
    if (!isSelected && !isViewAll) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final buttonBuyNow = context.lang('package_button_buy_now');
    final buttonViewDetails = context.lang('package_button_view_details');
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding7),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: kPadding7),
              child: ResultHeader(
                title: context.lang('package'),
                resultKey: 'package',
                resultCount: data.length,
                isShowViewAll: !isSelected && data.length > 5,
                onTapViewAll: onTapViewAll,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: kPadding7),
                  child: PackageCardWidget(
                    viewModel: packageCards[index],
                    searchPackageIconsModel: packageCards[index].icons,
                    onSelectBuyNow: onSelectBuyNow,
                    onSelectPackageById: onSelectPackageById,
                    buttonBuyNow: buttonBuyNow,
                    buttonViewDetails: buttonViewDetails,
                  ),
                );
              },
              childCount: isSelected ? packageCards.length : packageCards.take(5).length,
            ),
          ),
          if (!isSelected && data.length > 5)
            SliverToBoxAdapter(
              child: ViewAllTonalButton(
                resultNumber: data.length,
                title: context.lang(
                  'home_loyalty_link_view_all',
                ),
                onPressed: onTapViewAll,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(top: kPadding9))
        ],
      ),
    );
  }
}
