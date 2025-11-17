import 'package:equatable/equatable.dart';

class SearchProfileModel extends Equatable {
  final String? _mobileNumber;
  final String? _searchNtype;

  const SearchProfileModel({
    String? mobileNumber,
    String? searchNtype,
  })  : _mobileNumber = mobileNumber,
        _searchNtype = searchNtype;

  String? get mobileNumber => _mobileNumber;
  String? get searchNtype => _searchNtype;

  SearchProfileModel copyWith({
    String? mobileNumber,
    String? searchNtype,
  }) {
    return SearchProfileModel(
      mobileNumber: mobileNumber ?? _mobileNumber,
      searchNtype: searchNtype ?? _searchNtype,
    );
  }

  @override
  List<Object?> get props => [_mobileNumber, _searchNtype];
}
