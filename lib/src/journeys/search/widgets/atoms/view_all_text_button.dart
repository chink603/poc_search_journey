import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';

class ViewAllTextButton extends StatelessWidget {
  const ViewAllTextButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MyaButton(
      label: context.lang(
        'home_loyalty_link_view_all',
      ),
      suffixIconKey: 'iconui_general_chevron_right',
      theme: MyaButtonTheme.primary,
      style: MyaButtonStyle.text,
      size: MyaButtonSize.small,
      onPressed: onPressed,
      noRightPadding: true,
    );
  }
}
