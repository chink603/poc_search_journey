part of 'search_bloc.dart';

final class SearchStartEvent extends ODAStartEvent {}

final class SearchLoadEvent extends ODALoadEvent {
  final String searchText;
  final CheckRouteModel checkRouteModel;
  SearchLoadEvent({required this.searchText, required this.checkRouteModel});
}

final class SearchPressedEvent extends ODAPressedEvent {
  final String searchText;

  SearchPressedEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}

final class SelectCategoryEvent extends ODAPressedEvent {
  final String category;
  
  SelectCategoryEvent({required this.category});
  
  @override
  List<Object> get props => [category];
}

final class SelectSubCategoryEvent extends ODAPressedEvent {
  final String subCategory;
  
  SelectSubCategoryEvent({required this.subCategory});
  
  @override
  List<Object> get props => [subCategory];
}

final class HistoryDeleteSearchEvent extends ODAPressedEvent {}

final class HistoryAddSearchEvent extends ODAPressedEvent {
  final String searchText;

  HistoryAddSearchEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}



