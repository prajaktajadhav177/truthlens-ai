import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'result_screen.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> getComparisonData(String text) {
  final keywords = [
    "cracked",
    "placed",
    "salary",
    "package",
    "lpa",
    "faang",
    "internship",
    "offer",
    "google",
    "amazon",
  ];

  text = text.toLowerCase();

  List<String> found = [];

  for (var word in keywords) {
    if (text.contains(word)) {
      found.add(word);
    }
  }

  int score = (found.length * 15).clamp(0, 100);

  return {
    "score": score,
    "keywords": found,
  };
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

bool isSearching = false;
List<TextSpan> highlightText(String text, String query) {
  if (query.isEmpty) {
    return [TextSpan(text: text)];
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();

  final spans = <TextSpan>[];
  int start = 0;

  while (true) {
    final index = lowerText.indexOf(lowerQuery, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start)));
      break;
    }

    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }

    spans.add(
      TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    start = index + query.length;
  }

  return spans;
}

TextEditingController searchController = TextEditingController();
String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('historyBox');
    final keys = box.keys.toList().reversed.toList();
final history = keys.map((key) => box.get(key)).toList();

    return Scaffold(
      appBar: AppBar(
  title: isSearching
    ? TextField(
        controller: searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Search history...",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      )
    : const Text("History"),
  actions: [
    IconButton(
      icon: Icon(isSearching ? Icons.close : Icons.search),
     onPressed: () {
  setState(() {
    isSearching = !isSearching;

    if (!isSearching) {
      searchQuery = "";
      searchController.clear();
    }
  });
},
    ),

    IconButton(
      icon: const Icon(Icons.delete_forever),
      onPressed: () {
        final box = Hive.box('historyBox');
        box.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("History cleared")),
        );

        setState(() {});
      },
    ),
  ],
),
     body: history.isEmpty
    ? const Center(child: Text("No history yet"))
    : Column(
        children: [
         

          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
  final item = history[index];

  final inputRaw = item["input"] ?? "";
  final comparisonData = getComparisonData(inputRaw);

  final input = inputRaw.toString().toLowerCase();
if (searchQuery.isNotEmpty && !input.contains(searchQuery)) {
  return const SizedBox();
}

                final result = item["result"];

               String score = "0";

try {
  final parsed = jsonDecode(result);
  score = parsed["score"]?.toString() ?? "0";
} catch (e) {
  score = "N/A";
}

String time = "";

try {
  final dateTime = DateTime.parse(item["time"]);
time = DateFormat('dd MMM, hh:mm a').format(dateTime);
} catch (e) {
  time = "";
}

return Container(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(color: Colors.white.withOpacity(0.3)),
  ),
  child: ListTile(
    title: RichText(
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  text: TextSpan(
    children: highlightText(inputRaw, searchQuery),
    style: const TextStyle(color: Colors.black),
  ),
),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text("📊 Score: $score\n🕒 $time"),
    ),    isThreeLine: true,

    trailing: IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        final box = Hive.box('historyBox');
        box.delete(keys[index]);// correct index
        setState(() {}); // refresh UI
      },
    ),

    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => 
ResultScreen(
  result: result,
  recommendation: "",
  showAlert: comparisonData["score"] > 40,
),
        ),
      );
    },
  ),
);
              },
            ),
    )
        ]
    )
    );
  }
}