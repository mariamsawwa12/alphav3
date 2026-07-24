class OpenBankingAccount {
  final String accountId;
  final String status;
  final String statusUpdateDateTime;
  final String currency;
  final String accountType;
  final String accountSubType;
  final String description;
  final String nickname;

  OpenBankingAccount({
    required this.accountId,
    required this.status,
    required this.statusUpdateDateTime,
    required this.currency,
    required this.accountType,
    required this.accountSubType,
    required this.description,
    required this.nickname,
  });

  factory OpenBankingAccount.fromJson(Map<String, dynamic> json) {
    return OpenBankingAccount(
      accountId: json['AccountId']?.toString() ?? json['accountId']?.toString() ?? '',
      status: json['Status']?.toString() ?? json['status']?.toString() ?? 'Enabled',
      statusUpdateDateTime: json['StatusUpdateDateTime']?.toString() ?? json['statusUpdateDateTime']?.toString() ?? '',
      currency: json['Currency']?.toString() ?? json['currency']?.toString() ?? 'JOD',
      accountType: json['AccountType']?.toString() ?? json['accountType']?.toString() ?? 'Personal',
      accountSubType: json['AccountSubType']?.toString() ?? json['accountSubType']?.toString() ?? 'CurrentAccount',
      description: json['Description']?.toString() ?? json['description']?.toString() ?? '',
      nickname: json['Nickname']?.toString() ?? json['nickname']?.toString() ?? 'My Account',
    );
  }
}
