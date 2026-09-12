import 'package:alpha_app/models/home_model.dart';
import 'package:alpha_app/services/home_service.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  // =====================================================
  // STATE
  // =====================================================

  HomeModel? _homeData;

  HomeModel? get homeData => _homeData;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get hasData => _homeData != null;

  void enablePortfolioDemo() {
    _homeData = HomeModel.fromJson({
      'cycle': {
        'id': 'portfolio-cycle',
        'status': 'active',
        'startDate': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 22)).toIso8601String(),
        'daysRemaining': 22,
      },
      'income': {'expected': 1200, 'recorded': 1200, 'recurring': 1000, 'unexpected': 200},
      'buckets': {
        'needs': {'target': 600, 'actual': 340, 'remaining': 260, 'usagePercent': 56.7, 'status': 'healthy'},
        'wants': {'target': 360, 'actual': 145, 'remaining': 215, 'usagePercent': 40.3, 'status': 'healthy'},
        'savings': {'target': 240, 'actual': 180, 'remaining': 60, 'usagePercent': 75, 'status': 'on_track', 'plannedEmergencyFund': 100, 'plannedGoalAllocations': 140, 'unallocatedSavings': 0},
      },
      'goals': {'activeCount': 2, 'readyCount': 0, 'items': []},
      'commitments': {'totalReserved': 95, 'upcomingCount': 2, 'overdueCount': 0},
      'safeDailySpending': {'amount': 21.5, 'reliability': 'high', 'reasons': []},
      'comparison': {'previousPeriodAvailable': true, 'incomeChange': 8, 'expenseChange': -4, 'savingsChange': 12},
      'setupRequired': false,
      'reliability': 'high',
      'warnings': [],
    });
  }

  bool get hasError {
    return _errorMessage != null && _errorMessage!.trim().isNotEmpty;
  }

  // =====================================================
  // LOAD HOME DATA
  // =====================================================

  Future<void> loadHomeData({
    bool forceRefresh = false,
  }) async {
    if (_isLoading) {
      return;
    }

    if (_homeData != null && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // Load consolidated dashboard data from single backend endpoint
      final dashboardData = await HomeService.loadDashboard();

      _homeData = _buildHomeModel(dashboardData);

      _errorMessage = null;
    } catch (error) {
      debugPrint(
        'LOAD HOME DATA ERROR: $error',
      );

      _errorMessage = 'Failed to load home data';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // BUILD HOME MODEL
  // =====================================================

  HomeModel _buildHomeModel(
    Map<String, dynamic> dashboardData,
  ) {
    debugPrint(
        'HOME STATUS: hasActiveCycle=${dashboardData['cycle'] != null}, setupRequired=${dashboardData['setupRequired']}, warningCodes=${dashboardData['warnings']}');

    return HomeModel.fromJson(dashboardData);
  }

  // =====================================================
  // LOCAL UPDATES
  // =====================================================

  void setHomeData(
    HomeModel homeData,
  ) {
    _homeData = homeData;
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshHomeData() {
    return loadHomeData(
      forceRefresh: true,
    );
  }

  // =====================================================
  // ERROR
  // =====================================================

  void setError(
    String message,
  ) {
    _errorMessage = message;
    _isLoading = false;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // CLEAR
  // =====================================================

  void clearData() {
    _homeData = null;
    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }
}
