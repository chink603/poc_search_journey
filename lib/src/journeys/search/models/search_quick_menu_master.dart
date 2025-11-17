import 'package:equatable/equatable.dart';

class SearchQuickMenuMaster extends Equatable {
  final String id;
  final String name;
  final bool isOpen;
  final String urlScheme;
  final bool requireLogin;
  final String menuVersion;
  final String urlTH;
  final String urlEN;
  final String img;
  final bool isNew;
  final bool isSeemore;

  SearchQuickMenuMaster(
      {required this.id,
      required this.name,
      required this.isOpen,
      required this.urlScheme,
      required this.requireLogin,
      required this.menuVersion,
      required this.urlTH,
      required this.urlEN,
      required this.img,
      required this.isNew,
      this.isSeemore = false});

  SearchQuickMenuMaster copyWith({
    String? id,
    String? name,
    bool? isOpen,
    String? urlScheme,
    bool? requireLogin,
    String? menuVersion,
    String? urlTH,
    String? urlEN,
    String? fontSizeLine2,
    String? img,
    bool? isNew,
    bool? isSeemore,
  }) {
    return SearchQuickMenuMaster(
      id: id ?? this.id,
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      menuVersion: menuVersion ?? this.menuVersion,
      urlScheme: urlScheme ?? this.urlScheme,
      requireLogin: requireLogin ?? this.requireLogin,
      urlTH: urlTH ?? this.urlTH,
      urlEN: urlEN ?? this.urlEN,
      img: img ?? this.img,
      isNew: isNew ?? this.isNew,
      isSeemore: isSeemore ?? this.isSeemore,
    );
  }

  @override
  List<Object?> get props => [
        name,
        isOpen,
        urlScheme,
        requireLogin,
        menuVersion,
        urlTH,
        urlEN,
        img,
        isNew,
        isSeemore,
      ];
}
