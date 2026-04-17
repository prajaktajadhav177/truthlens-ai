import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String getSupportMessage(int score) {
  if (score < 30) {
    return "⚠️ This content may be misleading. Focus on real progress, not shortcuts.";
  } else if (score < 70) {
    return "💡 This shows partial truth. Success takes consistent effort.";
  } else {
    return "✅ This seems realistic. Still, everyone’s journey is different.";
  }
}

String getScoreExplanation(int score) {
  if (score < 30) {
    return "This post is likely unrealistic or misleading. It may create false expectations.";
  } else if (score < 70) {
    return "This post shows partial truth but may hide effort or challenges.";
  } else {
    return "This post appears realistic and reflects genuine effort and experience.";
  }
}

class ResultScreen extends StatefulWidget {
  final String result;

  final bool showAlert;
  final String recommendation;

const ResultScreen({
  super.key,
  required this.result,
    required this.recommendation,
  required this.showAlert,
});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
void _shareResult(Map<String, dynamic> parsed) {
  final text = """
Reality Score: ${parsed["score"] ?? "N/A"}

Exaggeration:
${parsed["exaggeration"]}

Hidden Effort:
${parsed["effort"]}

Advice:
${parsed["advice"]}

Smart Guidance:
${widget.recommendation}
""";

  if (kIsWeb) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  } else {
    Share.share(text);
  }
}

  @override
  Widget build(BuildContext context) {

Map<String, dynamic> parsed = {};
try {
  parsed = jsonDecode(widget.result);
} catch (e) {
  parsed = {};
}int score = int.tryParse(parsed["score"]?.toString() ?? "0") ?? 0;
String message = getSupportMessage(score);
String explanation = getScoreExplanation(score);


    return Scaffold(
        backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Analysis Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            
  children: [
  if (widget.showAlert) _buildAlertCard(),
  const SizedBox(height: 10),

  _buildSupportCard(message),
  const SizedBox(height: 20),

   Center(
    child: SizedBox(
      width: 180,
      child: _buildScoreCard(parsed["score"]?.toString() ?? "0"),
      
    ),
  ),
  const SizedBox(height: 20),

  _buildExplanationCard(explanation),

  ElevatedButton.icon(
  onPressed: () => _shareResult(parsed),
  icon: const Icon(Icons.share),
  label: const Text("Share Result"),
),
const SizedBox(height: 10),

  _buildCard(
  "Exaggeration",
  parsed["exaggeration"] ?? "No exaggeration detected."
),

_buildCard(
  "Hidden Effort",
parsed["effort"] ?? "No hidden effort found."
),

_buildCard(
  "Advice",
  (parsed["advice"] ?? "").toString().isEmpty
      ? "No advice available."
      : parsed["advice"].toString(),
),

const SizedBox(height: 10),
_buildCard("Smart Guidance", widget.recommendation),
],
)
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Card(
       shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
  children: [
    Icon(
  title == "Exaggeration"
      ? Icons.trending_up
      : title == "Hidden Effort"
          ? Icons.work
          : title == "Advice"
              ? Icons.lightbulb
              : Icons.psychology, // 👈 for Smart Guidance
  size: 18,
),
    const SizedBox(width: 6),
    Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ],
),
            const SizedBox(height: 10),
            highlightText(content),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String score) {
  int value = int.tryParse(score) ?? 0;

  Color color;
  if (value < 30) {
    color = Colors.red;
  } else if (value < 70) {
    color = Colors.orange;
  } else {
    color = Colors.green;
  }

  return TweenAnimationBuilder<int>(
    tween: IntTween(begin: 0, end: value),
    duration: const Duration(seconds: 1),
    builder: (context, val, child) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        color: color.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Reality Score",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                "$val",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildAlertCard() {
  return Card(
    color: Colors.red.shade100,
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This post may create unrealistic expectations. Don't compare blindly.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSupportCard(String message) {
  return Card(
    color: Colors.blue.shade50,
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue),
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

Widget _buildExplanationCard(String text) {
  return Card(
    color: Colors.purple.shade50,
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.insights, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget highlightText(String text) {
  final keywords = [
    "salary",
    "lpa",
    "faang",
    "cracked",
    "placed",
    "internship"
  ];

  List<TextSpan> spans = [];

  final words = text.split(RegExp(r'\s+'));
for (var word in words){
    final cleanWord = word.toLowerCase();

    if (keywords.any((k) => cleanWord.contains(k))) {
      spans.add(
        TextSpan(
          text: "$word ",
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: "$word ",
          style: const TextStyle(color: Colors.black),
        ),
      );
    }
  }

  return RichText(
    text: TextSpan(children: spans),
  );
}

}