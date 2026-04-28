import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService{

  static const String apiKey="AIzaSyAR-nZ2LeoEx3b5xKRqTKhhfoPZxOSjU7E";
static Future<String> analyzeText(String input) async {
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

      

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-goog-api-key": apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
              "text": """
Analyze the following social media post:

"$input"

Respond ONLY in JSON format:

{
  "score": number (0 to 100, where 0 = highly unrealistic, 100 = completely realistic),
  "exaggeration": "2 lines explaining exaggeration if any",
  "effort": "2 lines explaining hidden effort",
  "advice": "2 lines of helpful advice"
}
"""   
              }
            ]
          }
        ]
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (data['candidates'] != null && data['candidates'].isNotEmpty) {
final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

if (text == null) return "No response from AI";

try {
  String cleanText = text
    .replaceAll("```json", "")
    .replaceAll("```", "")
    .trim();

try {
  final json = jsonDecode(cleanText);
  return jsonEncode(json);
} catch (e) {
  print("JSON PARSE ERROR: $e");
  return cleanText;
}
} catch (e) {
  print("JSON PARSE ERROR: $e");
  return text; // fallback
}    }

    return "No response from AI";
  } catch (e) {
    print("ERROR: $e");
    return "Error occurred";
  }
}

static Future<String> getDecision(String input) async {
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-goog-api-key": apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
You are a friendly mentor helping a student.

Respond EXACTLY in this format:

Suggestion:
<short clear answer>

Why:
<2-3 lines>

Next Steps:
- step 1
- step 2
- step 3

Question:
"$input"
"""
              }
            ]
          }
        ]
      }),
    );

    print("DECISION STATUS: ${response.statusCode}");
    print("DECISION BODY: ${response.body}");

    if (response.statusCode != 200) {
      return "API Error: ${response.statusCode}";
    }

    final data = jsonDecode(response.body);

    if (data['candidates'] == null || data['candidates'].isEmpty) {
      return "No response from AI";
    }

    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'];

    return text ?? "No response from AI";
  } catch (e) {
    print("DECISION ERROR: $e");
    return "Error occurred";
  }
}

static Future<String> getRecommendation(String input) async {
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-goog-api-key": apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
You are a practical mentor helping a student avoid unhealthy comparison.

Based on this post:

"$input"

Respond in this format:

Reality Check:
<1 line>

Focus On:
<2 lines>

Ignore:
<1 line>
"""
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      return "Could not generate recommendation.";
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'];

    return text ?? "No recommendation available.";
  } catch (e) {
    return "Error getting recommendation.";
  }
}

}