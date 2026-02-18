import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:krishimitra_ai/core/constants/app_colors.dart';
import 'package:krishimitra_ai/core/constants/app_strings.dart';
import 'package:krishimitra_ai/presentation/pages/home/home_page.dart';
import 'services/localization/tts_service.dart';
import 'services/localization/tts_languages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (uncomment when Firebase is configured)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize Hive (local storage)
  // await Hive.initFlutter();

  // Setup dependency injection
  // await setupServiceLocator();
  await TtsService.instance.init(language: TtsLanguages.enIN);
  runApp(const KrishiMitraApp());
}

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Info
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theming
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light, // Change to ThemeMode.system for device theme

      // Localization Support
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('mr'), // Marathi
        Locale('bn'), // Bengali
        Locale('ta'), // Tamil
        Locale('te'), // Telugu
        Locale('kn'), // Kannada
        Locale('gu'), // Gujarati
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Home Page
      home: const HomePage(),
    );
  }
}
