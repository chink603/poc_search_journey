import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';
import '../../widgets/widgets.dart';

class HelpAndSupportResults extends StatelessWidget {
  const HelpAndSupportResults({
    super.key,
    required this.isSelected,
    required this.onTapViewAll,
    required this.data,
    required this.onTapCard,
  });

  final bool isSelected;
  final List<DocumentEntity> data;
  final VoidCallback onTapViewAll;
  final Function(String? id) onTapCard;

  @override
  Widget build(BuildContext context) {
    final myaColors = context.myaThemeColors;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kPadding7),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: kPadding7),
              child: ResultHeader(
                title: context.lang('home_search_faq_title'),
                resultKey: 'helpAndSupport',
                resultCount: data.length,
                isShowViewAll: !isSelected && data.length > 10,
                onTapViewAll: onTapViewAll,
              ),
            ),
          ),
          if (data.length == 1)
            SliverToBoxAdapter(
              child: Container(
                decoration: ShapeDecoration(
                  shadows: MyaElevation.getElevation(
                      context, MyaElevationLevel.elevation3),
                  color: myaColors.bgContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadius6),
                  ),
                ),
                child: MyaListItemGeneral(
                  titleText: data[0].name.toString(),
                  isDisabled: false,
                  suffixIconKey: 'iconui_general_chevron_right',
                  iconSuffixColor: myaColors.blackWhite,
                  isDivider: false,
                  onTap: () => onTapCard(data[0].id),
                ),
              ),
            ),
          if (data.length > 1)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final listLength =
                    isSelected ? data.length - 1 : data.take(10).length - 1;
                return Container(
                  decoration: ShapeDecoration(
                      color: myaColors.bgContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: (index == 0)
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(kRadius6),
                                topRight: Radius.circular(kRadius6),
                              )
                            : (index == listLength)
                                ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(kRadius6),
                                    bottomRight: Radius.circular(kRadius6),
                                  )
                                : BorderRadius.zero,
                      )),
                  child: MyaListItemGeneral(
                    titleText: data[index].name.toString(),
                    isDisabled: false,
                    suffixIconKey: 'iconui_general_chevron_right',
                    iconSuffixColor: myaColors.blackWhite,
                    isDivider: false,
                    onTap: () => onTapCard(data[index].id),
                  ),
                );
              }, childCount: isSelected ? data.length : data.take(10).length),
            ),
          if (!isSelected && data.length > 10)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: kPadding7),
                child: ViewAllTonalButton(
                  resultNumber: data.length,
                  title: context.lang(
                    'home_loyalty_link_view_all',
                  ),
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
