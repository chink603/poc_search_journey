import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';

import '../../models/models.dart';

class ListChipFilter extends StatefulWidget {
  const ListChipFilter({super.key, required this.list, required this.onTap});

  final List<SearchCategoryModel> list;
  final Function(String) onTap;

  @override
  State<ListChipFilter> createState() => _ListChipFilterState();
}

class _ListChipFilterState extends State<ListChipFilter> {
  List<GlobalKey> keys = [];

  @override
  void didUpdateWidget(covariant ListChipFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list.length != widget.list.length) {
      keys = List.generate(widget.list.length, (index) => GlobalKey());
    }
  }

  @override
  void initState() {
    super.initState();
    keys = List.generate(widget.list.length, (index) => GlobalKey());
  }

  void scrollToChip(GlobalKey key) {
    final selectedChipKey = key;
    final context = selectedChipKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.list
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                key: keys[entry.key],
                padding: const EdgeInsets.only(right: kPadding4),
                child: MyaChipFilter(
                    labelText: context.lang(entry.value.label),
                    size: MyaChipFilterSize.medium,
                    prefixIconKey: entry.value.icon,
                    isSelected: entry.value.value,
                    onPressed: () {
                      scrollToChip(keys[entry.key]);
                      widget.onTap(entry.value.label);
                    }),
              ),
            )
            .toList(),
      ),
    );
  }
}
