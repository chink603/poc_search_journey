import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../../cubit/search_result_cubit.dart';
import '../../models/models.dart';
import 'components.dart';

class SearchCategorySection extends StatefulWidget {
  const SearchCategorySection(
      {super.key,
      required this.categories,
      required this.onTapCategory,
      required this.onTapSubCategory});

  final List<SearchCategoryModel>? categories;
  final Function(SearchCategoryModel model) onTapCategory;
  final Function(SearchCategoryModel model) onTapSubCategory;

  @override
  State<SearchCategorySection> createState() => _SearchCategorySectionState();
}

class _SearchCategorySectionState extends State<SearchCategorySection> {
  List<SearchCategoryModel> categories = [];
  @override
  void initState() {
    super.initState();
    categories = widget.categories ?? [];
    if (categories.length == 1) {
      categories = categories.map((e) => e.copyWith(value: true)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: context.myaThemeColors.bgContainer,
          border: MyaDividerBorder(context, isShow: true)),
      padding: EdgeInsets.fromLTRB(kPadding7, kPadding1, kPadding7,
          categories.isNotEmpty ? kPadding4 : kPadding1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categories.isNotEmpty)
            ListChipFilter(
                list: categories,
                onTap: (SearchCategoryModel model) {
                  widget.onTapCategory(model);
                }),
          BlocBuilder<SearchResultCubit, ODACubitState>(
              builder: (context, state) {
            if (state is SearchResultSuccess) {
              if (state.subCategories.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: kPadding4),
                  child: ListChipFilter(
                    list: state.subCategories,
                    onTap: (SearchCategoryModel model) {
                      widget.onTapSubCategory(model);
                    },
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          })
        ],
      ),
    );
  }
}
