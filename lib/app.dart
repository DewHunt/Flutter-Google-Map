import 'package:flutter/material.dart';
import 'package:google_map/ui/screens/home_screen.dart';

class GoogleMapApps extends StatefulWidget {
  const GoogleMapApps({super.key});

  @override
  State<GoogleMapApps> createState() => _GoogleMapAppsState();
}

class _GoogleMapAppsState extends State<GoogleMapApps> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: _buildLightTheme(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size.fromWidth(double.maxFinite),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
