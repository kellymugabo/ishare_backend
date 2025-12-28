import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import 'firebase_options.dart';
import 'constants/app_theme.dart';

// --- Providers ---
import 'providers/locale_provider.dart';
import 'services/api_service.dart';

// --- Screens ---
import 'screens/welcome_screen.dart';
import 'screens/home/main_wrapper.dart';

// ✅ IMPORT THE FILE YOU JUST CREATED
import 'l10n/material_localizations_rw.dart'; 

// ⚠️ Fallback for iOS (Cupertino) widgets to prevent crashes
class RwCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const RwCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(const Locale('en')); 
  @override
  bool shouldReload(RwCupertinoLocalizationsDelegate old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ CRITICAL FIX: Initializes date formatting for all languages (rw, fr, en)
  await initializeDateFormatting(); 

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const ProviderScope(child: IShareApp()));
}

class IShareApp extends ConsumerWidget {
  const IShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(isLoggedInProvider);

    return MaterialApp(
      title: 'iShare Ride',
      debugShowCheckedModeBanner: false,

      // --- Localization Setup ---
      locale: currentLocale,
      
      supportedLocales: const [
        Locale('en'), // English
        Locale('rw'), // Kinyarwanda
        Locale('fr'), // French
      ],
      
      localizationsDelegates: const [
        // 1. Your App Translations (Strings inside .arb files)
        AppLocalizations.delegate,

        // 2. ✅ YOUR CUSTOM KINYARWANDA UI FIX (System buttons like OK/Cancel)
        RwMaterialLocalizationsDelegate(),

        // 3. The Custom Fallback for iOS/Cupertino Crash
        RwCupertinoLocalizationsDelegate(),

        // 4. Standard Flutter Delegates
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // --- Smart Fallback Logic ---
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },

      // --- Theme & Navigation ---
      theme: _buildThemeData(),
      
      home: authState.when(
        data: (isLoggedIn) {
          if (isLoggedIn) {
            return const MainWrapper();
          } else {
            return const WelcomeScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => const WelcomeScreen(),
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppTheme.primaryBlue, 
      scaffoldBackgroundColor: AppTheme.surfaceGrey,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryBlue,
        primary: AppTheme.primaryBlue,
        secondary: Colors.lightBlueAccent,
        brightness: Brightness.light,
        error: Colors.red[700],
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppTheme.textGrey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: AppTheme.textGrey),
        floatingLabelStyle: const TextStyle(color: AppTheme.primaryBlue),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.surfaceGrey,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.textDark),
        titleTextStyle: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}