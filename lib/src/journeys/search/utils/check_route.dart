import 'package:dartx/dartx.dart';
import 'package:oda_search_micro_journey/src/journeys/search/bloc/bloc.dart';

import '../models/models.dart';

enum CheckRouteEnum {
  tab,
  route,
  url,
  none;
}

class CheckRouteModel {
  final CheckRouteEnum type;
  final String? tabName;
  final String? routeName;
  final Map<String, String>? arguments;
  final String? urlName;
  final bool requestAuthen;
  const CheckRouteModel({
    required this.type,
    this.tabName,
    this.routeName,
    this.arguments,
    this.urlName,
    this.requestAuthen = true,
  });
}

class CheckRouteHelper {
  final String searchText;
  final FullConfig fullConfig;

  CheckRouteHelper({required this.searchText, required this.fullConfig});

  CheckRouteModel get getRouteModel => checkManageRoute();

  CheckRouteModel checkManageRoute() {
    final normalizedSelection = searchText.toLowerCase();

    final routeMatch = _findMainRoute(
      normalizedSelection,
    );
    if (routeMatch != null) {
      return _mapMainRouteToModel(routeMatch);
    }

    final subRouteMatch = _findSubRoute(normalizedSelection);
    if (subRouteMatch != null) {
      return _mapSubRouteToModel(subRouteMatch);
    }

    return const CheckRouteModel(type: CheckRouteEnum.none);
  }

  SearchKeywordConfig? _findMainRoute(String normalizedSelection) {
    for (final element in fullConfig.route) {
      if (element.keyword.toLowerCase() == normalizedSelection) {
        return element;
      }
    }
    return null;
  }

  SearchKeywordConfig? _findSubRoute(String normalizedSelection) {
    for (final element in fullConfig.subRoute) {
      if (element.keyword.toLowerCase() == normalizedSelection) {
        return element;
      }
    }
    return null;
  }

  CheckRouteModel _mapMainRouteToModel(SearchKeywordConfig route) {
    switch (route.navigation) {
      case 'Package':
        return const CheckRouteModel(
          type: CheckRouteEnum.tab,
          tabName: 'PACKAGE',
        );
      case 'Privileges':
        return const CheckRouteModel(
          type: CheckRouteEnum.tab,
          tabName: 'PRIVILEGE',
        );
      case 'Profile':
        return const CheckRouteModel(
          type: CheckRouteEnum.tab,
          tabName: 'PROFILE',
        );
      default:
        return const CheckRouteModel(type: CheckRouteEnum.none);
    }
  }

  CheckRouteModel _mapSubRouteToModel(SearchKeywordConfig subRoute) {
    final navigation = subRoute.navigation;

    if (navigation.isNullOrEmpty) {
      return const CheckRouteModel(type: CheckRouteEnum.none);
    }

    if (_isUrlNavigation(navigation)) {
      final url = navigation.toString();
      final isHelpAndSupport =
          url.contains('ais.th/consumers/help-and-support/myais3');

      return CheckRouteModel(
        type: CheckRouteEnum.url,
        urlName: url,
        requestAuthen: !isHelpAndSupport,
      );
    }

    final args = subRoute.arguments;
    if (args == null) {
      return CheckRouteModel(
        type: CheckRouteEnum.route,
        routeName: navigation,
      );
    }

    final hasSubCategory = args.subCategoryId != null;
    final hasCategory = args.categoryId != null;

    if (hasSubCategory && hasCategory) {
      return CheckRouteModel(
        type: CheckRouteEnum.route,
        routeName: navigation,
        arguments: {
          'catalogId': args.categoryId.toString(),
          'categoryId': args.subCategoryId.toString(),
        },
      );
    }

    if (!hasSubCategory && hasCategory) {
      return CheckRouteModel(
        type: CheckRouteEnum.route,
        routeName: navigation,
        arguments: {
          'catalogId': args.categoryId.toString(),
        },
      );
    }

    return CheckRouteModel(
      type: CheckRouteEnum.route,
      routeName: navigation,
    );
  }

  bool _isUrlNavigation(String navigation) {
    return navigation.contains('http') ||
        navigation.contains('https') ||
        navigation.contains('myais://');
  }
}
