// import 'package:flutter/material.dart';
// import '../../new_search_lib.dart';

// class PackageResults extends StatelessWidget {
//   const PackageResults({
//     super.key,
//     required this.coreLanguage,
//     required this.isSelected,
//     required this.data,
//     required this.dataOffer,
//     required this.onTapViewAll,
//     required this.onSelectPackageById,
//     required this.onSelectBuyNow,
//   });

//   final CoreLanguage coreLanguage;
//   final bool isSelected;
//   final List<PackageCardViewModel> data;
//   final List<ProductOffering> dataOffer;
//   final VoidCallback onTapViewAll;
//   final Function(ProductOffering?) onSelectPackageById;
//   final Function(String) onSelectBuyNow;

//   @override
//   Widget build(BuildContext context) {
//     final buttonBuyNow =
//         coreLanguage.getLanguageByKey('package_button_buy_now');
//     final buttonViewDetails =
//         coreLanguage.getLanguageByKey('package_button_view_details');
//     return SliverPadding(
//       padding: const EdgeInsets.symmetric(horizontal: kPadding7),
//       sliver: SliverMainAxisGroup(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: kPadding7),
//               child: ResultHeader(
//                 title: coreLanguage.getLanguageByKey('package'),
//                 coreLanguage: coreLanguage,
//                 resultKey: 'package',
//                 resultCount: dataOffer.length,
//                 isShowViewAll: !isSelected && dataOffer.length > 5,
//                 onTapViewAll: onTapViewAll,
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: kPadding7),
//                   child: context
//                           .watch<NewSearchPackageBloc>()
//                           .fetchedIconsIds
//                           .contains(index)
//                       ? NewPackageCardWidget(
//                           key: ValueKey(
//                               'myaisCommonSearch/package/cardPackage/$index'),
//                           viewModel: context
//                               .watch<NewSearchPackageBloc>()
//                               .listPackageCardViewModel[index],
//                           onSelectBuyNow: onSelectBuyNow,
//                           onSelectPackageById: onSelectPackageById,
//                           buttonBuyNow: buttonBuyNow,
//                           buttonViewDetails: buttonViewDetails,
//                         )
//                       : FutureBuilder<SearchPackageIconsModel>(
//                           future: packageCardHelper.getIconsPackage(
//                               dataOffer[index]),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               context.read<NewSearchPackageBloc>().add(
//                                   NewSearchPackageUpdateIconsEvent(
//                                       index: index,
//                                       searchPackageIconsModel: snapshot.data!));
//                             }
//                             // return const SizedBox.shrink();
//                             return NewPackageCardWidget(
//                               key: ValueKey(
//                                   'myaisCommonSearch/package/cardPackage/$index'),
//                               viewModel: data[index],
//                               searchPackageIconsModel: snapshot.data,
//                               onSelectBuyNow: onSelectBuyNow,
//                               onSelectPackageById: onSelectPackageById,
//                               buttonBuyNow: buttonBuyNow,
//                               buttonViewDetails: buttonViewDetails,
//                             );
//                           }),
//                 );
//               },
//               childCount: isSelected ? data.length : data.take(5).length,
//             ),
//           ),
//           if (!isSelected && dataOffer.length > 5)
//             SliverToBoxAdapter(
//               child: ViewAllTonalButton(
//                 coreLanguage: coreLanguage,
//                 resultNumber: dataOffer.length,
//                 title: coreLanguage.getLanguageByKey(
//                   'home_loyalty_link_view_all',
//                 ),
//                 onPressed: onTapViewAll,
//               ),
//             ),
//           const SliverPadding(padding: EdgeInsets.only(top: kPadding9))
//         ],
//       ),
//     );
//   }
// }
