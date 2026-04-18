import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'decision_screen.dart';
import 'progress_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const DecisionScreen(),
    const ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RealityCheck AI")),

      // 👉 Drawer (sidebar like ChatGPT)
      drawer: Drawer(
        child: Column(
          children: [
            Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Icon(Icons.psychology, color: Colors.indigo),
      ),
      SizedBox(height: 12),
      Text(
        "RealityCheck AI",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 4),
      Text(
        "Think clearly. Decide better.",
        style: TextStyle(color: Colors.white70),
      ),
    ],
  ),
),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "General",
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
      ),
    ),
  ),
),

          ListTile(
  leading: const Icon(Icons.history, color: Colors.indigo),
  title: const Text("History"),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );
  },
),

     ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.orange),
        title: const Text("Tips"),
        onTap: () {},
      ),

      // 🔥 STEP 5 — ADD AT VERY BOTTOM
      const Spacer(),   // pushes below items down

      const Divider(),

      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text("About"),
        onTap: () {},
      ),
    

          ],
        ),
      ),

      body: screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: "Decision",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Progress",
          ),
        ],
      ),
    );
  }
}