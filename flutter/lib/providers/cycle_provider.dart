import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/services/api_service.dart';
import 'package:alpha_app/services/api_exception.dart';

class CycleProvider extends ChangeNotifier {
  bool _portfolioDemo = false;
  dynamic _currentCycle;
  bool _isLoading = false;
  bool _isCreatingCycle = false;
  String? _error;

  dynamic get currentCycle => _currentCycle;
  bool get hasActiveCycle => _currentCycle != null;
  bool get isLoading => _isLoading;
  bool get isCreatingCycle => _isCreatingCycle;
  String? get error => _error;

  void clearData() {
    _currentCycle = null;
    _isLoading = false;
    _isCreatingCycle = false;
    _error = null;
    notifyListeners();
  }

  void enablePortfolioDemo() {
    _portfolioDemo = true;
    _currentCycle = {
      'id': 'portfolio-cycle',
      'status': 'active',
      'startDate':
          DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 22)).toIso8601String(),
      'daysRemaining': 22,
    };
  }

  Future<void> loadCurrentCycle() async {
    if (_portfolioDemo) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/financial-cycles/current');

      if (response == null) {
        throw const ApiException(message: "تعذر الاتصال بالخادم");
      }

      final Map<String, dynamic> body = await ApiService.parseJson(response);

      if (response.statusCode == 200) {
        _currentCycle = body['data'] ?? body;
        _error = null;
      } else if (response.statusCode == 404) {
        final code = body['error']?['code'] ?? body['code'];
        if (code == 'CYCLE_NOT_FOUND') {
          // Normal state: User has no active cycle
          _currentCycle = null;
          _error = null;
        } else {
          _currentCycle = null;
          throw ApiException(
            message: await ApiService.getErrorMessage(response,
                fallback: 'دورة مالية غير موجودة'),
            statusCode: 404,
            code: code,
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Leave to interceptors/session flow, but set error
        _currentCycle = null;
        throw ApiException(
          message: "انتهت الجلسة أو غير مصرح لك.",
          statusCode: response.statusCode,
        );
      } else {
        _currentCycle = null;
        throw ApiException(
          message: await ApiService.getErrorMessage(response,
              fallback: "تعذر تحميل الدورة المالية"),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = "تعذر الاتصال بالخادم";
      }
      _currentCycle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCycle(
      Map<String, dynamic> cycleData, OnboardingProvider onboarding) async {
    if (!onboarding.isOnboarded || !onboarding.canCreateCycle) {
      _error = "الملف المالي غير مكتمل أو لا يمكنك إنشاء دورة حالياً.";
      notifyListeners();
      return false;
    }

    _isCreatingCycle = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await ApiService.post('/financial-cycles', body: cycleData);

      if (response == null) {
        throw const ApiException(message: "تعذر الاتصال بالخادم");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentCycle = data['data'] ?? data;
        return true;
      } else if (response.statusCode == 409) {
        throw ApiException(
          message: "توجد دورة مالية مفتوحة بالفعل.",
          statusCode: 409,
        );
      } else {
        throw ApiException(
          message: await ApiService.getErrorMessage(response,
              fallback: "فشل إنشاء الدورة المالية"),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = "تعذر الاتصال بالخادم";
      }
      return false;
    } finally {
      _isCreatingCycle = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getCyclePlanningSummary(String cycleId) async {
    if (_portfolioDemo) {
      return {
        'plannedSavings': 300.0,
        'emergencyFundTarget': 1800.0,
        'emergencyFundBalance': 420.0,
        'goalAllocations': [
          {
            'goal_type': 'travel',
            'is_system_managed': false,
            'planned_amount': 60.0
          },
        ],
        'savingsAllocation': {'emergency_fund_rate': 20.0},
      };
    }
    try {
      final response =
          await ApiService.get('/financial-cycles/$cycleId/planning-summary');
      if (response != null && response.statusCode == 200) {
        final body = await ApiService.parseJson(response);
        return body['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cycle planning summary: $e');
      return null;
    }
  }

  Future<bool> linkSavingsAllocation(
      String cycleId, double emergencyFundPercentage) async {
    if (_portfolioDemo) {
      _error = null;
      return true;
    }
    try {
      final response = await ApiService.post(
        '/financial-cycles/$cycleId/savings-allocation',
        body: {'emergencyFundPercentage': emergencyFundPercentage},
      );
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return true;
      }
      _error = await _handleSavingsError(response, "فشل حفظ التخصيص");
      notifyListeners();
      return false;
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = "تعذر الاتصال بالخادم";
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSavingsAllocation(
      String cycleId, double emergencyFundPercentage) async {
    if (_portfolioDemo) {
      _error = null;
      return true;
    }
    try {
      final response = await ApiService.put(
        '/financial-cycles/$cycleId/savings-allocation',
        body: {'emergencyFundPercentage': emergencyFundPercentage},
      );
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return true;
      }
      _error = await _handleSavingsError(response, "فشل تحديث التخصيص");
      notifyListeners();
      return false;
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = "تعذر الاتصال بالخادم";
      }
      notifyListeners();
      return false;
    }
  }

  Future<String> _handleSavingsError(dynamic response, String fallback) async {
    if (response == null) return fallback;
    try {
      final body = await ApiService.parseJson(response);
      final code = body['error']?['code'] ?? body['code'];
      switch (code) {
        case 'SYSTEM_EMERGENCY_FUND_NOT_FOUND':
          return "لم يتم العثور على صندوق طوارئ مرتبط بحسابك. أكمل إعداد صندوق الطوارئ أولًا.";
        case 'DUPLICATE_SYSTEM_EMERGENCY_FUND':
          return "يوجد صندوق طوارئ مرتبط بالحساب مسبقًا.";
        case 'SAVINGS_ALLOCATION_NOT_FOUND':
          return "أعد تحميل الملخص، وإذا لم يعد هناك تخصيص استخدم POST بدل PUT عند المحاولة التالية.";
        case 'INVALID_PERCENTAGE':
          return "يجب أن تكون النسبة بين 0 و100.";
        case 'SAVINGS_EXCEEDED':
        case 'SAVINGS_INVARIANT_VIOLATION':
          return "مجموع تخصيصات الادخار يتجاوز المدخرات المخططة.";
        case 'CYCLE_NOT_ACTIVE':
        case 'INVALID_CYCLE_STATE':
          return "لا يمكن تعديل تخصيص الادخار بعد إغلاق الدورة.";
        default:
          return await ApiService.getErrorMessage(response, fallback: fallback);
      }
    } catch (_) {
      return fallback;
    }
  }

  String _cleanError(dynamic error) {
    return error.toString().replaceAll('Exception:', '').trim();
  }
}
