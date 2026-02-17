import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/product_page.dart';

import 'package:provider/provider.dart';
import 'package:formation_flutter/providers/recall_fetcher.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecallFetcher()),
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
        colorScheme: .fromSeed(seedColor: AppColors.nutriscoreA),
        fontFamily: 'Avenir',
        textTheme: TextTheme(headlineMedium: TextStyle()),
      ),
      debugShowCheckedModeBanner: false,
      home: const ProductPage(),
    );
  }
}
