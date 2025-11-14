part of 'search_bloc.dart';

final class SearchStartEvent extends ODAStartEvent {}

final class SearchLoadEvent extends ODALoadEvent {
  final String searchText;
  final String language;
  SearchLoadEvent({required this.searchText, required this.language});

  @override
  List<Object> get props => [searchText];
}

final class SearchPressedEvent extends ODAPressedEvent {}
