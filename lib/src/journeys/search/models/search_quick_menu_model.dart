import 'package:equatable/equatable.dart';

class SearchQuickMenuModel extends Equatable {
  final String id;
  final String name;
  final bool isOpen;
  final String urlScheme;
  final bool requireLogin;
  final String urlTH;
  final String urlEN;
  final String img;
  final bool isNew;

  const SearchQuickMenuModel({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.urlScheme,
    required this.requireLogin,
    required this.urlTH,
    required this.urlEN,
    required this.img,
    required this.isNew,
  });

  SearchQuickMenuModel copyWith({
    String? id,
    String? name,
    bool? isOpen,
    String? urlScheme,
    bool? requireLogin,
    String? urlTH,
    String? urlEN,
    String? fontSizeLine2,
    String? img,
    bool? isNew,
  }) {
    return SearchQuickMenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      urlScheme: urlScheme ?? this.urlScheme,
      requireLogin: requireLogin ?? this.requireLogin,
      urlTH: urlTH ?? this.urlTH,
      urlEN: urlEN ?? this.urlEN,
      img: img ?? this.img,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [
        name,
        isOpen,
        urlScheme,
        requireLogin,
        urlTH,
        urlEN,
        img,
        isNew,
      ];
}
