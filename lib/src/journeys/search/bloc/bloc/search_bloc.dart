import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oda_data_tmf667_document_management/oda_data_tmf667_document_management.dart';
import 'package:oda_fe_framework/oda_framework.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends OdaBloc<ODAEvent, ODAState> {
  final SearchFaqsUsecase searchFaqsUsecase;
  SearchBloc({
    required super.context,
    required this.searchFaqsUsecase,
  }) : super(initialState: SearchInitialState()) {
    on<SearchStartEvent>((event, emit) {
      print('SearchStartEvent');
    });
    on<SearchLoadEvent>((event, emit) async {
      emit(SearchLoadingState());
      final result = await searchFaqsUsecase.call(input: event.searchText, language: event.language);
      await Future.delayed(const Duration(seconds: 2));
      emit(SearchSuccessState());
    });
    on<SearchPressedEvent>((event, emit) {});
  }
}
