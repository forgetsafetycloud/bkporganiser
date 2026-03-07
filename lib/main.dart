import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'providers/storage_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    // Initialize SQLite for Web
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Check if we are on a desktop platform (Windows, Linux, macOS)
    // Dart:io is not available on web, so we must safely check.
    // If not web, we can import dart:io. Since this code runs on non-web, it's safe.
    _initDesktopDbFactory();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

// Separate function so dart compiler doesn't trip on dart:io import when compiling for web
void _initDesktopDbFactory() {
  // Use conditional import to avoid issues on web compilation
  // Although not strictly necessary since kIsWeb guards execution, it's cleaner.
  // Actually, standard check:
  bool isDesktop = false;
  try {
    // This is a simple trick to check platform without importing dart:io directly
    final String platformStr = defaultTargetPlatform.toString();
    if (platformStr.contains('windows') || platformStr.contains('linux') || platformStr.contains('macOS')) {
      isDesktop = true;
    }
  } catch (_) {}

  if (isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cyberpunk Theme Definitions
    final cyberNeonGreen = const Color(0xFF00FF00);
    final cyberDarkBg = const Color(0xFF111111);
    final cyberCardBg = const Color(0xFF1A1A1A);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StorageProvider()),
      ],
      child: MaterialApp(
        title: 'Backup Organiser Terminal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: cyberDarkBg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: cyberNeonGreen,
            brightness: Brightness.dark,
            primary: cyberNeonGreen,
            surface: cyberCardBg,
            onSurface: Colors.white70,
          ),
          textTheme: GoogleFonts.shareTechMonoTextTheme(
             ThemeData.dark().textTheme.copyWith(
               bodyLarge: const TextStyle(color: Colors.white, fontSize: 16),
               bodyMedium: const TextStyle(color: Colors.white70),
               titleLarge: TextStyle(color: cyberNeonGreen, fontWeight: FontWeight.bold),
             )
          ),
          appBarTheme: AppBarTheme(
             backgroundColor: cyberDarkBg,
             foregroundColor: cyberNeonGreen,
             elevation: 0,
             centerTitle: false,
             titleTextStyle: GoogleFonts.shareTechMono(
                color: cyberNeonGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
             )
          ),
          dialogTheme: DialogTheme(
            backgroundColor: cyberCardBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: cyberNeonGreen.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(4),
            )
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
             backgroundColor: cyberDarkBg,
             foregroundColor: cyberNeonGreen,
             shape: RoundedRectangleBorder(
                side: BorderSide(color: cyberNeonGreen, width: 2),
                borderRadius: BorderRadius.circular(4),
             )
          )
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
