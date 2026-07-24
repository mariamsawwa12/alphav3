class OpenBankingBalance {
  final String accountId;
  final String amount;
  final String currency;
  final String creditDebitIndicator;
  final String type;

  OpenBankingBalance({
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.creditDebitIndicator,
    required this.type,
  });

  factory OpenBankingBalance.fromJson(Map<String, dynamic> json) {
    String parsedAmount = '0.00';
    String parsedCurrency = 'USD';

    if (json['Amount'] != null) {
      if (json['Amount'] is Map) {
        parsedAmount = json['Amount']['Amount']?.toString() ?? '0.00';
        parsedCurrency = json['Amount']['Currency']?.toString() ?? 'USD';
      } else {
        parsedAmount = json['Amount'].toString();
      }
    } else if (json['amount'] != null) {
      if (json['amount'] is Map) {
        parsedAmount = json['amount']['Amount']?.toString() ?? json['amount']['amount']?.toString() ?? '0.00';
        parsedCurrency = json['amount']['Currency']?.toString() ?? json['amount']['currency']?.toString() ?? 'USD';
      } else {
        parsedAmount = json['amount'].toString();
      }
    }

    return OpenBankingBalance(
      accountId: json['AccountId']?.toString() ?? json['accountId']?.toString() ?? '',
      amount: parsedAmount,
      currency: parsedCurrency,
      creditDebitIndicator: json['CreditDebitIndicator']?.toString() ?? json['creditDebitIndicator']?.toString() ?? 'Credit',
      type: json['Type']?.toString() ?? json['type']?.toString() ?? 'Available',
    );
  }
}
