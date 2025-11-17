// import 'package:flutter/material.dart';
// import 'package:oda_presentation_loyalty_management/utils/widget/local/loyalty_card_product_information/loyalty_card_production_information.dart';
// import '../../new_search_lib.dart';

// class PrivilegeResults extends StatelessWidget {
//   final List<LoyaltyProgramProductSpec> data;
//   const PrivilegeResults({
//     super.key,
//     required this.coreLanguage,
//     required this.data,
//     required this.isSelected,
//     required this.onTapViewAll,
//     required this.onTapCard,
//   });

//   final CoreLanguage coreLanguage;
//   final bool isSelected;
//   final VoidCallback onTapViewAll;
//   final Function(int) onTapCard;
//   @override
//   Widget build(BuildContext context) {
//     return SliverPadding(
//       padding: const EdgeInsets.symmetric(horizontal: kPadding7),
//       sliver: SliverMainAxisGroup(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: kPadding7),
//               child: ResultHeader(
//                 title: coreLanguage
//                     .getLanguageByKey('bottom_navigation_privileges'),
//                 coreLanguage: coreLanguage,
//                 resultKey: 'privilege',
//                 resultCount: data.length,
//                 isShowViewAll: !isSelected && data.length > 10,
//                 onTapViewAll: onTapViewAll,
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate((context, index) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: kPadding6),
//                 child: MyaLoyaltyCardProductionInformation
//                     .withRealmLoyaltyProductSpecObject(
//                   product: data[index],
//                   onTapCard: (String? s) => onTapCard(index),
//                 ),
//               );
//             }, childCount: isSelected ? data.length : data.take(10).length),
//           ),
//           if (!isSelected && data.length > 10)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.only(top: kPadding3),
//                 child: ViewAllTonalButton(
//                   coreLanguage: coreLanguage,
//                   resultNumber: data.length,
//                   title: coreLanguage.getLanguageByKey(
//                     'home_loyalty_link_view_all',
//                   ),
//                   onPressed: onTapViewAll,
//                 ),
//               ),
//             ),
//           const SliverPadding(padding: EdgeInsets.only(top: kPadding9))
//         ],
//       ),
//     );
//   }
// }
