import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';

import '../atoms/atoms.dart';
import '../../utils/util.dart';

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
    required this.resultKey,
    required this.resultCount,
    required this.title,
    this.isShowViewAll = true,
    this.onTapViewAll,
  });

  final String resultKey;
  final int resultCount;
  final String title;
  final bool isShowViewAll;
  final VoidCallback? onTapViewAll;

  @override
  Widget build(BuildContext context) {
    final myaColors = context.myaThemeColors;
    final myaTextStyles = context.myaTextStyle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: myaTextStyles.titleSmall.copyWith(
                color: myaColors.textIconText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              key: ValueKey('myaisCommonSearch/$resultKey/supportingText'),
              '$resultCount ${context.lang('search_result_word_result')}',
              style: myaTextStyles.bodyMediumExtraThin
                  .copyWith(color: myaColors.textIconSubdued),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const Spacer(),
        if (isShowViewAll)
          ViewAllTextButton(onPressed: onTapViewAll)
      ],
    );
  }
}
