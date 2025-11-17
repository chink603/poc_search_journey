import 'package:flutter/material.dart';
import 'package:mya_ui_design/mya_ui_design.dart';
import 'package:oda_fe_framework/oda_framework.dart';
import '../../utils/util.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class TodayCouponResults extends StatelessWidget {
  const TodayCouponResults({
    super.key,
    required this.isSelected,
    required this.data,
    required this.onTapViewAll,
    required this.onTapCard,
  });

  final bool isSelected;
  final List<SearchCouponViewModel> data;
  final VoidCallback onTapViewAll;
  final Function(int index) onTapCard;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: kPadding7, left: kPadding7, right: kPadding7),
            child: ResultHeader(
              title: context.lang('home_loyalty_label_topic_today_coupon'),
              resultKey: 'todayCoupon',
              resultCount: data.length,
              isShowViewAll: !isSelected && data.length > 3,
              onTapViewAll: onTapViewAll,
            ),
          ),
        ),
        isSelected
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: kPadding5, left: kPadding7, right: kPadding7),
                      child: MyaCardCoupon(
                        key: const ValueKey(
                            'myaisCommonSearch/todayCoupon/${MyaCardCoupon.compType}'),
                        imageUrl: data[index].imageUrl,
                        overlayText: data[index].overlayText,
                        headingText: data[index].title,
                        descriptionText: data[index].description,
                        isShowButton: data[index].isShowButton,
                        buttonLabel: context.lang(
                            'home_loyalty_button_collect_coupon'),
                        onPressed: () => onTapCard(index),
                      ),
                    );
                  },
                  childCount: data.length,
                ),
              )
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: 136,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.925),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: index == 0 ? kPadding1 : kPadding4),
                        child: MyaCardCoupon(
                          key: const ValueKey(
                              'myaisCommonSearch/todayCoupon/${MyaCardCoupon.compType}'),
                          imageUrl: data[index].imageUrl,
                          overlayText: data[index].overlayText,
                          headingText: data[index].title,
                          descriptionText: data[index].description,
                          isShowButton: data[index].isShowButton,
                          buttonLabel: context.lang(
                              'home_loyalty_button_collect_coupon'),
                          onPressed: () => onTapCard(index),    
                        ),
                      );
                    },
                  ),
                ),
              ),
        const SliverPadding(padding: EdgeInsets.only(top: kPadding9))
      ],
    );
  }
}
