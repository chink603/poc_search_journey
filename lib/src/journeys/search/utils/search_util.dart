// import 'package:oda_data_tmf658_loyalty_management/domain/domain.dart' as tmf658;
import 'package:oda_data_schema/main.core.export.dart';
import 'package:oda_data_tmf658_loyalty_management/data/extensions/loyalty_program_product_spec_extension.dart';

class SearchUtil {
  // Cache สำหรับ expensive operations
  static final Map<String, int> _priorityCache = {};
  static final Map<String, num> _pointsCache = {};
  static final Map<String, bool> _hasPointsCache =
      {}; // เพิ่ม cache สำหรับ hasPoints
  static Map<String, String> _categoryCache =
      {}; // เพิ่ม cache สำหรับ category
  static const String categoryPoint = 'POINT';
  static const String categoryPrivilege = 'PRIVILEGE';
  static void clearAllCaches() {
    _priorityCache.clear();
    _pointsCache.clear();
    _hasPointsCache.clear();
    _categoryCache.clear();
  }

  static Future<List<LoyaltyProgramProductSpec>> sortCampaigns(
      List<LoyaltyProgramProductSpec> campaigns, int selectedSort) async {
    if (campaigns.isEmpty) return campaigns;
    if (selectedSort == 0) return campaigns;
    if (selectedSort == 1) {
      return _sortByTimestamp(campaigns);
    } else if (selectedSort == 2) {
      return _sortByPrivilege(campaigns);
    } else if (selectedSort == 3) {
      return _sortByPointsAscending(campaigns);
    } else if (selectedSort == 4) {
      return _sortByPointsDescending(campaigns);
    }
    return campaigns;
  }

  static List<LoyaltyProgramProductSpec> _sortByTimestamp(
      List<LoyaltyProgramProductSpec> campaigns) {
    final sortedCampaigns =
        List<LoyaltyProgramProductSpec>.from(campaigns);

    sortedCampaigns.sort((a, b) {
      final aTime = a.ts.timestamp;
      final bTime = b.ts.timestamp;
      return bTime.compareTo(aTime); // เรียงจากใหม่ไปเก่า
    });

    return sortedCampaigns;
  }

  static Future<List<LoyaltyProgramProductSpec>> _sortByPrivilege(
      List<LoyaltyProgramProductSpec> campaigns) async {
    // First, filter to get only the PRIVILEGE campaigns.
    final List<LoyaltyProgramProductSpec> privilegeCampaigns = [];
    
    // Filter campaigns asynchronously
    for (var campaign in campaigns) {
      if (await _getCachedCategoryType(campaign) == categoryPrivilege) {
        privilegeCampaigns.add(campaign);
      }
    }

    // Pre-fetch priorities for sorting
    final Map<String, int> priorityMap = {};
    for (var campaign in privilegeCampaigns) {
      priorityMap[campaign.id] = await _getCachedPriority(campaign);
    }

    // Now, sort the filtered list by priority.
    privilegeCampaigns.sort((a, b) {
      final aPriority = priorityMap[a.id] ?? 999;
      final bPriority = priorityMap[b.id] ?? 999;
      return bPriority.compareTo(aPriority); // Higher priority first
    });

    return privilegeCampaigns;
  }

  static Future<List<LoyaltyProgramProductSpec>> _sortByPointsAscending(
      List<LoyaltyProgramProductSpec> campaigns) async {
    // 1. Filter first to get only campaigns that have points.
    final campaignsWithPoints = await Future.wait(campaigns.map((c) async {
      return await _hasPointsCategoryCached(c) ? c : null;
    })).then((list) => list.whereType<LoyaltyProgramProductSpec>().toList());

    // 2. Pre-fetch all points values
    final Map<String, num> pointsMap = {};

    for (var campaign in campaignsWithPoints) {
      pointsMap[campaign.id] = await _getCachedPoints(campaign);
    }


    // 3. Sort the filtered list.
    campaignsWithPoints.sort((a, b) {
      final aPoints = pointsMap[a.id] ?? 0;
      final bPoints = pointsMap[b.id] ?? 0;
      return aPoints.compareTo(bPoints); // Ascending
    });

    return campaignsWithPoints;
  }

  static Future<List<LoyaltyProgramProductSpec>> _sortByPointsDescending(
      List<LoyaltyProgramProductSpec> campaigns) async {
    // 1. Filter first to get only campaigns that have points.
    final campaignsWithPoints = await Future.wait(campaigns.map((c) async {
      return await _hasPointsCategoryCached(c) ? c : null;
    })).then((list) => list.whereType<LoyaltyProgramProductSpec>().toList());

    // 2. Pre-fetch all points values
    final Map<String, num> pointsMap = {};
    for (var campaign in campaignsWithPoints) {
      pointsMap[campaign.id] = await _getCachedPoints(campaign);
    }

    // 3. Sort the filtered list using the pre-fetched values
    campaignsWithPoints.sort((a, b) {
      final aPoints = pointsMap[a.id] ?? 0;
      final bPoints = pointsMap[b.id] ?? 0;
      return bPoints.compareTo(aPoints); // Descending
    });

    return campaignsWithPoints;
  }

  // Helper methods with caching
  static Future<int> _getCachedPriority(LoyaltyProgramProductSpec campaign) async {
    final cacheKey = campaign.id;

    if (!_priorityCache.containsKey(cacheKey)) {
      try {
        _priorityCache[cacheKey] = await campaign.getCampaignPriority();
      } catch (e) {
        _priorityCache[cacheKey] = 999;
      }
    }

    return _priorityCache[cacheKey]!;
  }

  static Future<num> _getCachedPoints(LoyaltyProgramProductSpec campaign) async {
    final cacheKey = campaign.id;

    if (!_pointsCache.containsKey(cacheKey)) {
      try {
        _pointsCache[cacheKey] = toNumSafe(await campaign.getPoints(isPureData: false));
      } catch (e) {
        _pointsCache[cacheKey] = 0;
      }
    }

    return _pointsCache[cacheKey]!;
  }

  static Future<String> _getCachedCategoryType(
      LoyaltyProgramProductSpec campaign) async {
    final cacheKey = campaign.id;

    if (!_categoryCache.containsKey(cacheKey)) {
      try {
        final categoryFuture = await campaign.category;
        final categoryName = categoryFuture.isNotEmpty
            ? categoryFuture.first.TORO_categoryType ?? ''
            : '';
        _categoryCache[cacheKey] = categoryName;
      } catch (e) {
        _categoryCache[cacheKey] = '';
      }
    }

    return _categoryCache[cacheKey]!;
  }

  static Future<bool> _hasPointsCategoryCached(
      LoyaltyProgramProductSpec campaign) async {
    final cacheKey = campaign.id;

    if (!_hasPointsCache.containsKey(cacheKey)) {
      try {
        bool hasPoints = false;
        hasPoints = await _getCachedCategoryType(campaign) == categoryPoint;
        _hasPointsCache[cacheKey] = hasPoints;
      } catch (e) {
        _hasPointsCache[cacheKey] = false;
      }
    }

    return _hasPointsCache[cacheKey]!;
  }

  static num toNumSafe(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    final str = value.toString();
    final parsed = num.tryParse(str);
    return parsed ?? 0;
  }

  static void setCacheCategory(Map<String, String> cache) {
    if (cache.isNotEmpty) {
      _categoryCache = cache;
    }
  }
}
