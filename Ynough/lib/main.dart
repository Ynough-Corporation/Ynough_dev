import 'package:flutter/material.dart';
import 'navbar/navbar.dart';

const _ynoughBlack = Color(0xFF0A0A0A);
const _ynoughGreen = Color(0xFF3E5F44);
const _ynoughCream = Color(0xFFFFF7EB);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ynough',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: _ynoughGreen,
          onPrimary: _ynoughCream,
          secondary: _ynoughGreen,
          onSecondary: _ynoughCream,
          surface: _ynoughCream,
          onSurface: _ynoughBlack,
          error: Color(0xFFB3261E),
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: _ynoughCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: _ynoughGreen,
          foregroundColor: _ynoughCream,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _ynoughGreen,
          indicatorColor: _ynoughBlack,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              color: _ynoughCream,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: isSelected ? _ynoughCream : _ynoughCream.withValues(alpha: 0.72),
            );
          }),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
