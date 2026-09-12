import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/challenge_provider.dart';
import 'package:alpha_app/providers/chatbot_provider.dart';
import 'package:alpha_app/providers/cycle_provider.dart';
import 'package:alpha_app/providers/expense_provider.dart';
import 'package:alpha_app/providers/financial_analysis_provider.dart';
import 'package:alpha_app/providers/financial_profile_provider.dart';
import 'package:alpha_app/providers/financial_setup_provider.dart';
import 'package:alpha_app/providers/goal_provider.dart';
import 'package:alpha_app/providers/home_provider.dart';
import 'package:alpha_app/providers/income_provider.dart';
import 'package:alpha_app/providers/language_provider.dart';
import 'package:alpha_app/providers/leaderbord_provider.dart';
import 'package:alpha_app/providers/notification_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/personal_provider.dart';
import 'package:alpha_app/providers/profile_provider.dart';
import 'package:alpha_app/providers/receipt_provider.dart';
import 'package:alpha_app/providers/reward_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final onboarding = OnboardingProvider()..enablePortfolioDemo();
  final cycle = CycleProvider()..enablePortfolioDemo();
  final home = HomeProvider()..enablePortfolioDemo();
  final profile = ProfileProvider()..enablePortfolioDemo();
  final expenses = ExpenseProvider(initialize: false)..enablePortfolioDemo();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Themeprovider()..loadtheme()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider.value(value: onboarding),
          ChangeNotifierProvider(create: (_) => IncomeProvider()),
          ChangeNotifierProvider(create: (_) => PersonalProvider()),
          ChangeNotifierProvider(create: (_) => FinancialProfileProvider()),
          ChangeNotifierProvider(create: (_) => FinancialProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider.value(value: cycle),
          ChangeNotifierProvider(create: (_) => ChallengeProvider()),
          ChangeNotifierProvider(create: (_) => RewardProvider()),
          ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
          ChangeNotifierProvider(create: (_) => ChatbotProvider()),
          ChangeNotifierProvider.value(value: home),
          ChangeNotifierProvider(create: (_) => ReceiptProvider()),
          ChangeNotifierProvider.value(value: expenses),
          ChangeNotifierProvider(create: (_) => FinancialAnalysisProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: const AlphaPortfolioApp(),
      ),
    ),
  );
}

class AlphaPortfolioApp extends StatelessWidget {
  const AlphaPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Themeprovider>(
      builder: (_, theme, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: theme.thememode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
