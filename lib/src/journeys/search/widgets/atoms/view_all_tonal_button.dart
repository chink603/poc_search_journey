import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';

class ViewAllTonalButton extends StatelessWidget {
  const ViewAllTonalButton({
    super.key,
    required this.resultNumber,
    required this.title,
    this.onPressed,
  });

  final int resultNumber;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MyaButton(
            key: const ValueKey(
                'myaisCommonSearch/package/${MyaButton.compType}'),
            theme: MyaButtonTheme.primary,
            size: MyaButtonSize.large,
            style: MyaButtonStyle.tonalFilled,
            label:
                '$title ($resultNumber ${context.lang("search_result_button_viewall_word_results")})',
            suffixIconKey: 'iconui_general_chevron_right',
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}
