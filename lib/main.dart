import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:truth_lens/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('historyBox');
  runApp(const TruthLensApp());
}

class TruthLensApp extends StatelessWidget {
  const TruthLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RealityCheck AI',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
  primaryColor: const Color(0xFF4F46E5), // Indigo
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),
      home: MainScreen()
    );
  }
}
