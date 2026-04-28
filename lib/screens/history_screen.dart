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

Color _getScoreColor(String score) {
  int val = int.tryParse(score) ?? 0;

  if (val < 30) return Colors.red;
  if (val < 70) return Colors.orange;
  return Colors.green;
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
        decoration: InputDecoration(
  hintText: "Search history...",
  filled: true,
  fillColor: Colors.grey.shade100,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide.none,
  ),
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
    ? Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.history, size: 50, color: Colors.indigo.shade200),
      const SizedBox(height: 12),
      const Text(
        "No history yet",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(
        "Start analyzing posts to see insights here",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    ],
  ),
)
    : Column(
        children: [
         

          Expanded(
            child: ListView.separated(
              itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
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

return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border(
    left: BorderSide(
      color: _getScoreColor(score),
      width: 4,
    ),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
),
  child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),    child: Material(
      color: Colors.transparent,
  child: InkWell(
    splashColor: Colors.indigo.withOpacity(0.1),
highlightColor: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            recommendation: "",
            showAlert: comparisonData["score"] > 40,
          ),
        ),
      );
    },
      child: ListTile(
        title: RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: highlightText(inputRaw, searchQuery),
        style: const TextStyle(
  color: Colors.black,
  fontSize: 15,
  fontWeight: FontWeight.w500,
),
      ),
      ),
        subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
      
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),              decoration: BoxDecoration(
                color: _getScoreColor(score).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Score: $score",
                style: TextStyle(
                  fontSize: 13,
                    letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(score),
                ),
              ),
            ),
      
            const SizedBox(width: 10),
      
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
      ),   isThreeLine: true,
      
        trailing: IconButton(
          icon: Container(
  padding: const EdgeInsets.all(6),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade600),
),
          onPressed: () {
            final box = Hive.box('historyBox');
            box.delete(keys[index]);
            setState(() {}); 
          },
        ),
      
        ),
    ),
  ),
)
);
              },
            ),
    )
        ]
    )
    );
  }
}