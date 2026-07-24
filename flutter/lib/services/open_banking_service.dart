import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alpha_app/models/open_banking_account_model.dart';
import 'package:alpha_app/models/open_banking_balance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OpenBankingService {
  // Base URLs as per JoPACC portal structure
  static const String _accountsBaseUrl =
      'http://jpcjofsdev.apigw-az-eu.webmethods.io/gateway/Accounts/v0.4.3';
  static const String _balancesBaseUrl =
      'http://jpcjofsdev.apigw-az-eu.webmethods.io/gateway/Balances/v0.4.3';

  // Fetch token and auth from SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? 'SOME_STRING_VALUE';
    
    return {
      'x-customer-user-agent': 'AlphaApp/1.0',
      'x-financial-id': 'SOME_STRING_VALUE', // e.g. "Bank Identifier"
      'x-idempotency-key': DateTime.now().millisecondsSinceEpoch.toString(),
      'x-jws-signature': 'SOME_STRING_VALUE',
      'x-customer-ip-address': '127.0.0.1',
      'x-auth-date': DateTime.now().toIso8601String(),
      'x-customer-id': 'SOME_STRING_VALUE',
      'Authorization': 'Bearer $token',
      'x-interactions-id': 'SOME_STRING_VALUE',
      'Accept': 'application/json',
    };
  }

  Future<List<OpenBankingAccount>> fetchAccounts() async {
    try {
      final url = Uri.parse('$_accountsBaseUrl/accounts');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        print('Accounts API Response: $decodedData');
        List<dynamic> accountsList = [];

        if (decodedData is Map) {
          final dataObj = decodedData['Data'] ?? decodedData['data'];
          if (dataObj is Map) {
            accountsList = dataObj['Account'] ?? dataObj['account'] ?? [];
          } else if (dataObj is List) {
            accountsList = dataObj;
          } else if (decodedData['Account'] != null) {
             accountsList = decodedData['Account'];
          } else if (decodedData['account'] != null) {
             accountsList = decodedData['account'];
          } else {
             accountsList = [decodedData];
          }
        } else if (decodedData is List) {
          accountsList = decodedData;
        }

        if (accountsList.isEmpty) {
          // Fallback to Mock Data for UI testing
          accountsList = [
            {
              "AccountId": "101",
              "Account": [
                {
                  "SchemeName": "UK.OBIE.SortCodeAccountNumber",
                  "Identification": "12345678",
                  "Name": "Primary Checking"
                }
              ],
              "AccountType": "Personal",
              "AccountSubType": "CurrentAccount",
              "Currency": "JOD",
              "Nickname": "Salary Account"
            },
            {
              "AccountId": "102",
              "Account": [
                {
                  "SchemeName": "UK.OBIE.SortCodeAccountNumber",
                  "Identification": "87654321",
                  "Name": "Savings Account"
                }
              ],
              "AccountType": "Personal",
              "AccountSubType": "Savings",
              "Currency": "USD",
              "Nickname": "Emergency Fund"
            }
          ];
        }

        return accountsList
            .map((json) => OpenBankingAccount.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch accounts. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Open Banking accounts: $e');
    }
  }

  Future<OpenBankingBalance> fetchBalances(String accountId) async {
    try {
      final url = Uri.parse('$_balancesBaseUrl/accounts/$accountId/balances');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        List<dynamic> balancesList = [];

        if (decodedData is Map) {
          final dataObj = decodedData['Data'] ?? decodedData['data'];
          if (dataObj is Map) {
            balancesList = dataObj['Balance'] ?? dataObj['balance'] ?? [];
          } else if (dataObj is List) {
            balancesList = dataObj;
          } else if (decodedData['Balance'] != null) {
             balancesList = decodedData['Balance'];
          } else if (decodedData['balance'] != null) {
             balancesList = decodedData['balance'];
          } else {
             balancesList = [decodedData];
          }
        } else if (decodedData is List) {
          balancesList = decodedData;
        }

        if (balancesList.isEmpty) {
          // MOCK DATA for Balances
          balancesList = [
            {
              "AccountId": accountId,
              "Amount": {
                "Amount": accountId == "101" ? "1250.50" : "5000.00",
                "Currency": accountId == "101" ? "JOD" : "USD"
              },
              "CreditDebitIndicator": "Credit",
              "Type": "Available"
            }
          ];
        }

        if (balancesList.isNotEmpty) {
          return OpenBankingBalance.fromJson(balancesList.first);
        } else {
          throw Exception('No balances found for account $accountId');
        }
      } else {
        throw Exception('Failed to fetch balances. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Open Banking balances for $accountId: $e');
    }
  }
}
