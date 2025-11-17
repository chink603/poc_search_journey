import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';


class ResultWord extends StatelessWidget {
  final String searchWord;
  const ResultWord({super.key, required this.searchWord});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(kPadding7, kPadding3, kPadding7, kPadding7),
      sliver: SliverToBoxAdapter(
        child: Text(
          key: ValueKey('myaisCommonSearch/searchResult/$searchWord'),
          '${context.lang('search_header_search_result_word')} "$searchWord"',
          style: context.myaTextStyle.titleSmall
              .copyWith(color: context.myaThemeColors.textIconText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
