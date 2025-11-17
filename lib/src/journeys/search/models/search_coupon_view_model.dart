import 'package:equatable/equatable.dart';

class SearchCouponViewModel extends Equatable {
  final String id;
  final String description;
  final String title;
  final String? point;
  final String imageUrl;
  final String productNumber;
  final String? overlayText;
  final bool isShowButton;

  const SearchCouponViewModel(
      {required this.id,
      required this.description,
      required this.title,
      required this.point,
      required this.imageUrl,
      required this.productNumber,
      required this.overlayText,
      this.isShowButton = true});

  SearchCouponViewModel copyWith(
      {String? id,
      String? description,
      String? title,
      String? point,
      String? imageUrl,
      String? productNumber,
      String? overlayText,
      bool? isShowButton}) {
    return SearchCouponViewModel(
      id: id ?? this.id,
      description: description ?? this.description,
      title: title ?? this.title,
      point: point ?? this.point,
      imageUrl: imageUrl ?? this.imageUrl,
      productNumber: productNumber ?? this.productNumber,
      overlayText: overlayText ?? this.overlayText,
      isShowButton: isShowButton ?? this.isShowButton,
    );
  }

  const SearchCouponViewModel.empty() : this(
      id: '',
      description: '',
      title: '',
      point: '',
      imageUrl: '',
      productNumber: '',
      overlayText: '',
      isShowButton: true);

  @override
  List<Object?> get props =>
      [id, description, title, point, imageUrl, productNumber, overlayText,isShowButton];
}
