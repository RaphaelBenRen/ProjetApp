import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/product_page.dart';
import 'package:formation_flutter/screens/login_screen.dart';

import 'package:provider/provider.dart';
import 'package:formation_flutter/providers/recall_fetcher.dart';
import 'package:formation_flutter/providers/auth_provider.dart';
import 'package:formation_flutter/services/pocketbase_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PocketBaseService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<PocketBaseService>()),
        ),
        ChangeNotifierProxyProvider<PocketBaseService, RecallFetcher>(
          create: (context) => RecallFetcher(context.read<PocketBaseService>()),
          update: (context, service, fetcher) =>
              fetcher ?? RecallFetcher(service),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        extensions: [OffThemeExtension.defaultValues()],
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.nutriscoreA),
        fontFamily: 'Avenir',
        textTheme: const TextTheme(headlineMedium: TextStyle()),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      return const ProductPage();
    } else {
      return const LoginScreen();
    }
  }
}
