import 'package:flutter/material.dart';
import 'package:truth_lens/services/ai_service.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});


  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

Map<String, String> parseChat(String text) {
  text = text.replaceAll("**", ""); // remove markdown

  final suggestion = RegExp(r"Suggestion:\s*(.*?)(\n|$)", dotAll: true)
      .firstMatch(text)
      ?.group(1) ?? "";

  final why = RegExp(r"Why:\s*(.*?)(\n|$)", dotAll: true)
      .firstMatch(text)
      ?.group(1) ?? "";

  final steps = RegExp(r"Next Steps:\s*([\s\S]*)", dotAll: true)
      .firstMatch(text)
      ?.group(1) ?? "";

  return {
    "suggestion": suggestion.trim(),
    "why": why.trim(),
    "steps": steps.trim(),
  };
}

class _DecisionScreenState extends State<DecisionScreen> {
  TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  List<Map<String, String>> messages = [];

  void _sendMessage() async {
    String input = _controller.text.trim();

    if (input.isEmpty || isLoading) return;

setState(() {
  isLoading = true;
  messages.add({"role": "user", "text": input});
  messages.add({"role": "bot", "text": "..."});
});

      Future.delayed(const Duration(milliseconds: 100), () {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
});

    _controller.clear();

    String response = await AIService.getDecision(input);

   setState(() {
      isLoading = false;
  messages.removeLast();
  messages.add({"role": "bot", "text": response});
});

Future.delayed(const Duration(milliseconds: 100), () {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
});
  }

  @override
void initState() {
  super.initState();

  messages.add({
    "role": "bot",
    "text": "Hey 👋 I'm your AI mentor.\nAsk me anything about career, confusion, or decisions."
  });
}


bool _isStructured(String text) {
  return text.contains("Suggestion:") &&
         text.contains("Why:") &&
         text.contains("Next Steps:");
}
  Widget _buildMessage(Map<String, String> msg) {
  bool isUser = msg["role"] == "user";

  return Row(
    mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!isUser)
        const CircleAvatar(
          radius: 16,
          child: Icon(Icons.psychology, size: 18),
        ),

      const SizedBox(width: 6),

      Flexible(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
  color: isUser
      ? Colors.blue.shade100
      : Colors.grey.shade100,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    )
  ],
),
         child: msg["text"] == "..."
    ? const Center(
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
    : msg["role"] == "bot"
        ? _isStructured(msg["text"]!)
            ? _buildBotResponse(msg["text"]!)
            : Text(
                msg["text"]!,
                style: const TextStyle(fontSize: 14),
              )
        : Text(
            msg["text"]!,
            style: const TextStyle(fontSize: 14),
          )
    
        ),
      ),

      const SizedBox(width: 6),

      if (isUser)
        const CircleAvatar(
          radius: 16,
          child: Icon(Icons.person, size: 18),
        ),

           ],
  );
  
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Decision Assistant"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
          child: messages.isEmpty
        ? Center(
            child: Text(
              "Ask something like:\n\n• Which tech should I learn?\n• I'm confused about career\n• What should I do next?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(messages[index]);
            },
          ),
        ),
        
            // INPUT BAR
            Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                )
              ],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask your question...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
            ],
          ),
        )
          ],
        ),
      ),
    );
  }

  Widget _buildBotResponse(String text) {
  final parsed = parseChat(text);

  List<Widget> widgets = [];

  if (parsed["suggestion"]!.isNotEmpty) {
widgets.add(_section("Suggestion", parsed["suggestion"]!, Icons.lightbulb, Colors.orange));  }

  if (parsed["why"]!.isNotEmpty) {
widgets.add(_section("Why", parsed["why"]!, Icons.psychology, Colors.blue));  }

  if (parsed["steps"]!.isNotEmpty) {
widgets.add(_section("Next Steps", parsed["steps"]!, Icons.rocket_launch, Colors.green));  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

Widget _section(String title, String content, IconData icon, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(content),
            ],
          ),
        ),
      ],
    ),
  );
}
}