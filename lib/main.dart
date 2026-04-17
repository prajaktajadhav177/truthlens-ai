import 'package:flutter/material.dart';
import 'package:truth_lens/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      theme: ThemeData(primarySwatch:Colors.blue),
      home: HomeScreen()
    );
  }
}
