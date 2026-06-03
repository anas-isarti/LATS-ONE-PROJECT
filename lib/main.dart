import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'controllers/quest_controller.dart';
import 'controllers/nfc_controller.dart';
import 'screens/home_screen.dart';
import 'screens/city_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider(create: (_) => QuestController()),
        ChangeNotifierProvider(create: (_) => NfcController()),
      ],
      child: const TheLastOneApp(),
    ),
  );
}

class TheLastOneApp extends StatelessWidget {
  const TheLastOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Last One',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1A1A1A),
          elevation: 2,
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFFFFD700),
          unselectedLabelColor: Colors.white38,
          indicatorColor: Color(0xFFFFD700),
          labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFFFD700),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF4CAF50),
          linearTrackColor: Colors.white12,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/city': (_) => const CityScreen(),
      },
    );
  }
}
 
