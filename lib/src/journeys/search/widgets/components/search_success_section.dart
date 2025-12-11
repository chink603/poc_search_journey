import 'package:oda_fe_framework/oda_framework.dart';
import 'package:oda_search_micro_journey/src/journeys/search/models/models.dart';

import '../../cubit/search_result_cubit.dart';
import '../../utils/util.dart';
import '../widgets.dart';

class SearchSuccessSection extends StatefulWidget {
  const SearchSuccessSection(
      {super.key, required this.searchResultModel, required this.searchText});

  final SearchResultModel searchResultModel;
  final String searchText;

  @override
  State<SearchSuccessSection> createState() => _SearchSuccessSectionState();
}

class _SearchSuccessSectionState extends State<SearchSuccessSection> {
  @override
  void initState() {
    super.initState();
    context
        .read<SearchResultCubit>()
        .setUpResult(widget.searchResultModel, widget.searchText);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultCubit, ODACubitState>(
      builder: (context, state) {
        if (state is SearchResultSuccess) {
          return SliverMainAxisGroup(
            slivers: [
              ResultWord(searchWord: widget.searchText),
              if (state.searchResultModel.quickMenuList?.isNotEmpty ?? false)
                QuickMenuResults(
                  data: state.searchResultModel.quickMenuList!,
                  isSelected:
                      state.selectedCategoryType == CategoryType.quickMenu,
                  isViewAll: state.selectedCategoryType == CategoryType.none,
                  onTapViewAll: () {},
                  onTapCard: (int index) {},
                ),
              if (state.searchResultModel.packageList?.isNotEmpty ?? false)
                PackageResults(
                  data: state.searchResultModel.packageList!,
                  packageCards: state.packageCards,
                  isSelected:
                      state.selectedCategoryType == CategoryType.package,
                  isViewAll: state.selectedCategoryType == CategoryType.none,
                  onTapViewAll: () async {},
                  onSelectPackageById: (value) {},
                  onSelectBuyNow: (value) {},
                ),
              if (state.loyaltyProductList?.isNotEmpty ?? false)
                PrivilegeResults(
                    data: state.loyaltyProductList!,
                    sortedBy: state.campaignsSortedBy,
                    count: state.campaignCount,
                    isSelected: state.selectedCategoryType == CategoryType.privilege,
                    isViewAll: state.selectedCategoryType == CategoryType.none,
                    onTapViewAll: () {},
                    onTapCard: (index) {}),
              if (state.searchResultModel.faqList?.isNotEmpty ?? false)
                HelpAndSupportResults(
                  data: state.searchResultModel.faqList!,
                  isSelected: state.selectedCategoryType == CategoryType.faq,
                  isViewAll: state.selectedCategoryType == CategoryType.none,
                  onTapViewAll: () {},
                  onTapCard: (String? id) {},
                ),
            ],
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
