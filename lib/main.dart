import 'package:flutter/material.dart';
import 'settings/app_settings.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (_, mode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: AppSettings.accentColor,
          builder: (_, accent, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: accent,
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: accent,
                  brightness: Brightness.dark,
                ),
              ),
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}





