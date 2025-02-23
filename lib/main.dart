import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:freefood/providers/theme_provider.dart';
import 'package:freefood/screens/splash_screen.dart';
import 'package:freefood/utils/logo_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freefood/utils/constants.dart';
import 'package:web/web.dart' as web;
import 'package:freefood/providers/filter_provider.dart';

Future<void> initializeWeb() async {
  if (!kIsWeb) return;
  
  // Wait for Google Maps to be available
  await Future.delayed(const Duration(seconds: 2));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Text(
          'An error occurred: ${details.exception}',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  };

  try {
    if (kIsWeb) {
      await initializeWeb();
    }
    final prefs = await SharedPreferences.getInstance();
    
    if (kDebugMode) {
      print('Initializing FreeFood app...');
    }

    // Skip logo generation on web
    if (!kIsWeb && kDebugMode) {
      LogoGenerator.generateLogos();
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => FilterProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final textTheme = TextTheme(
          displayLarge: const TextStyle(fontFamily: 'Poppins'),
          displayMedium: const TextStyle(fontFamily: 'Poppins'),
          displaySmall: const TextStyle(fontFamily: 'Poppins'),
          headlineLarge: const TextStyle(fontFamily: 'Poppins'),
          headlineMedium: const TextStyle(fontFamily: 'Poppins'),
          headlineSmall: const TextStyle(fontFamily: 'Poppins'),
          titleLarge: const TextStyle(fontFamily: 'Poppins'),
          titleMedium: const TextStyle(fontFamily: 'Poppins'),
          titleSmall: const TextStyle(fontFamily: 'Poppins'),
          bodyLarge: const TextStyle(fontFamily: 'Poppins'),
          bodyMedium: const TextStyle(fontFamily: 'Poppins'),
          bodySmall: const TextStyle(fontFamily: 'Poppins'),
          labelLarge: const TextStyle(fontFamily: 'Poppins'),
          labelMedium: const TextStyle(fontFamily: 'Poppins'),
          labelSmall: const TextStyle(fontFamily: 'Poppins'),
        );

        return MaterialApp(
          title: 'FreeFood',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            textTheme: textTheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            textTheme: textTheme,
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
} 