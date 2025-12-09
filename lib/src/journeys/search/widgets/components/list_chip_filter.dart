import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';

import '../../models/models.dart';

class ListChipFilter extends StatefulWidget {
  const ListChipFilter({super.key, required this.list, required this.onTap, this.isDisable = false});

  final List<SearchCategoryModel> list;
  final Function(SearchCategoryModel) onTap;
  final bool isDisable;

  @override
  State<ListChipFilter> createState() => _ListChipFilterState();
}

class _ListChipFilterState extends State<ListChipFilter> {
  List<GlobalKey> keys = [];
  List<SearchCategoryModel> list = [];

  @override
  void didUpdateWidget(covariant ListChipFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list.length != widget.list.length) {
      keys = List.generate(widget.list.length, (index) => GlobalKey());
      list = widget.list;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    keys = List.generate(widget.list.length, (index) => GlobalKey());
    list = widget.list;
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

  void selectedChip(String label) {
    if (list.length == 1 && !widget.isDisable) return;
    SearchCategoryModel? selected;
    list = list.map((e) {
      final isTarget = e.label == label;
      final updated = e.copyWith(value:widget.isDisable ? false : isTarget ? !e.value : false);

      if (isTarget) {
        selected = updated;
      }

      return updated;
    }).toList();
    if(selected != null) {
      widget.onTap(selected!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list
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
                      selectedChip(entry.value.label);
                      scrollToChip(keys[entry.key]);
                    }),
              ),
            )
            .toList(),
      ),
    );
  }
}
