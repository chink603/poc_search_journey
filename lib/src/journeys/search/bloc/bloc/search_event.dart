part of 'search_bloc.dart';

final class SearchStartEvent extends ODAStartEvent {}

final class SearchLoadEvent extends ODALoadEvent {
  final String searchText;

  SearchLoadEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}

final class SearchPressedEvent extends ODAPressedEvent {
  final String searchText;

  SearchPressedEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}

final class DeleteHistoryEvent extends ODAPressedEvent {}

final class AddHistorySearchEvent extends ODAPressedEvent {
  final String searchText;

  AddHistorySearchEvent({required this.searchText});

  @override
  List<Object> get props => [searchText];
}



