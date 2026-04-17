import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  
  @override
 Widget build(BuildContext context) {
  final box = Hive.box('historyBox');
  final history = box.values.toList();

  List<int> scores = [];

  for (var item in history) {
    try {
      final parsed = jsonDecode(item["result"]);
      final score = int.tryParse(parsed["score"].toString()) ?? 0;
      scores.add(score);
    } catch (e) {}
  }

  List<FlSpot> spots = [];
  for (int i = 0; i < scores.length; i++) {
    spots.add(FlSpot(i.toDouble(), scores[i].toDouble()));
  }

  int total = scores.length;
  int avg = total > 0 ? (scores.reduce((a, b) => a + b) ~/ total) : 0;
  int max = total > 0 ? scores.reduce((a, b) => a > b ? a : b) : 0;
  int min = total > 0 ? scores.reduce((a, b) => a < b ? a : b) : 0;

  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    appBar: AppBar(title: const Text("Your Progress")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Your Growth Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: spots.length < 2
    ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.show_chart, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text("Need more data to show trend"),
        ],
      )
    : LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              color: Colors.blue,
              belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),

            ),
          ],
        ),
      ),
            ),

            const SizedBox(height: 20),

            _buildCard("📊 Average Score", avg.toString(), Colors.blue),
            _buildCard("📈 Highest Score", max.toString(), Colors.green),
            _buildCard("📉 Lowest Score", min.toString(), Colors.red),
            _buildCard("🔢 Total Analyses", total.toString(), Colors.purple),

            const SizedBox(height: 10),

            _buildInsight(avg, total),

            _buildActivity(total),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInsight(int avg, int total) {
  String message = "";

  if (total == 0) {
    message = "Start analyzing posts to see your progress.";
  } else if (avg < 30) {
    message =
        "⚠️ You are engaging with many unrealistic posts. Be mindful of comparison.";
  } else if (avg < 70) {
    message =
        "💡 You are seeing mixed content. Stay focused on consistent growth.";
  } else {
    message =
        "✅ You are engaging with realistic content. Great mindset!";
  }

  return Card(
    color: Colors.orange.shade100,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
  child: Text(
    message,
    style: const TextStyle(fontWeight: FontWeight.w500),
  ),
),
        ],
      ),
    ),
  );
}

Widget _buildActivity(int total) {
  String level;

  if (total < 3) level = "Low";
  else if (total < 10) level = "Moderate";
  else level = "High";

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: ListTile(
      leading: const Icon(Icons.local_fire_department, color: Colors.red),
      title: const Text("Activity Level"),
      trailing: Text(
        level,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
  title.contains("Average")
      ? Icons.bar_chart
      : title.contains("Highest")
          ? Icons.trending_up
          : title.contains("Lowest")
              ? Icons.trending_down
              : Icons.numbers,
  color: color,
),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}