
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../../models/models.dart';
import '../../utils/util.dart';
import 'components.dart';

class SearchCategorySection extends StatefulWidget {
  const SearchCategorySection(
      {super.key, required this.categories, required this.subCategories});

  final List<SearchCategoryModel>? categories;
  final Map<CategoryType, List<SearchCategoryModel>>? subCategories;

  @override
  State<SearchCategorySection> createState() => _SearchCategorySectionState();
}

class _SearchCategorySectionState extends State<SearchCategorySection> {
  @override
  Widget build(BuildContext context) {
    if(widget.categories == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
          color: context.myaThemeColors.bgContainer,
          border: MyaDividerBorder(context, isShow: true)),
      padding: EdgeInsets.fromLTRB(kPadding7, kPadding1, kPadding7,
          widget.categories!.isNotEmpty ? kPadding4 : kPadding1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.categories!.isNotEmpty)
            ListChipFilter(
                list: widget.categories!,
                onTap: (String label) {
                  // if (state.categories.length > 1) {
                  //   context
                  //       .read<NewSearchMainBloc>()
                  //       .add(SearchSelectedChipEvent(label));
                  // }
                }),
          // if (widget.subCategories != null)
          //   Padding(
          //     padding: const EdgeInsets.only(top: kPadding4),
          //     child: ListChipFilter(
          //         list: widget.subCategories, onTap: (String label) {}),
          //   ),
        ],
      ),
    );
  }
}
