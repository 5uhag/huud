import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const HuudApp());
}

class HuudApp extends StatelessWidget {
  const HuudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.purpleAccent,
          surface: Colors.black,
        ),
        fontFamily: GoogleFonts.getFont('JetBrains Mono').fontFamily,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
