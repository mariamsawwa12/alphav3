import 'package:flutter/material.dart';
import 'package:alpha_app/models/open_banking_account_model.dart';
import 'package:alpha_app/models/open_banking_balance_model.dart';
import 'package:alpha_app/services/open_banking_service.dart';

class OpenBankingProvider with ChangeNotifier {
  final OpenBankingService _service = OpenBankingService();

  List<OpenBankingAccount> _accounts = [];
  Map<String, OpenBankingBalance> _balances = {};
  
  bool _isLoadingAccounts = false;
  bool _isLoadingBalances = false;
  String? _errorMessage;

  List<OpenBankingAccount> get accounts => _accounts;
  Map<String, OpenBankingBalance> get balances => _balances;
  bool get isLoadingAccounts => _isLoadingAccounts;
  bool get isLoadingBalances => _isLoadingBalances;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAccountsAndBalances() async {
    _isLoadingAccounts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _service.fetchAccounts();
      _isLoadingAccounts = false;
      notifyListeners();

      // Fetch balances for each account
      await _fetchAllBalances();
    } catch (e) {
      _isLoadingAccounts = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchAllBalances() async {
    if (_accounts.isEmpty) return;

    _isLoadingBalances = true;
    notifyListeners();

    for (var account in _accounts) {
      try {
        final balance = await _service.fetchBalances(account.accountId);
        _balances[account.accountId] = balance;
      } catch (e) {
        debugPrint('Failed to load balance for ${account.accountId}: $e');
      }
    }

    _isLoadingBalances = false;
    notifyListeners();
  }
}
