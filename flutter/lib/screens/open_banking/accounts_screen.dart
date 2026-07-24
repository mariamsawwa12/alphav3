import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/providers/open_banking_provider.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpenBankingProvider>().fetchAccountsAndBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<Themeprovider>();
    final isDark = themeProvider.isDark;
    final provider = context.watch<OpenBankingProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'My Bank Accounts',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? AppColors.darkText : AppColors.lightText),
      ),
      body: _buildBody(provider, isDark),
    );
  }

  Widget _buildBody(OpenBankingProvider provider, bool isDark) {
    if (provider.isLoadingAccounts) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
      );
    }

    if (provider.errorMessage != null && provider.accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load accounts:\n${provider.errorMessage}',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.fetchAccountsAndBalances(),
                child: Text('Retry', style: GoogleFonts.ibmPlexSansArabic()),
              )
            ],
          ),
        ),
      );
    }

    if (provider.accounts.isEmpty) {
      return Center(
        child: Text(
          'No bank accounts linked yet.',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.accounts.length,
      itemBuilder: (context, index) {
        final account = provider.accounts[index];
        final balance = provider.balances[account.accountId];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      account.nickname,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: account.status.toLowerCase() == 'enabled'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: account.status.toLowerCase() == 'enabled'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${account.accountType} - ${account.accountSubType}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkSubText : AppColors.lightSubText,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                    ),
                  ),
                  if (provider.isLoadingBalances && balance == null)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (balance != null)
                    Text(
                      '${balance.amount} ${balance.currency}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    )
                  else
                    Text(
                      '---',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: isDark
                            ? AppColors.darkSubText
                            : AppColors.lightSubText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
