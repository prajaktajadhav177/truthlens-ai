import 'package:flutter/material.dart';
import 'package:truth_lens/screens/decision_screen.dart';
import 'package:truth_lens/screens/history_screen.dart';
import 'package:truth_lens/screens/progress_screen.dart';
import 'package:truth_lens/screens/result_screen.dart';
import 'package:truth_lens/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';

Future<void> saveHistory(String input, String result) async {
  final box = Hive.box('historyBox');

  box.add({
    "input": input,
    "result": result,
    "time": DateTime.now().toString(),
  });
}

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


class HomeScreen extends StatefulWidget{
    const HomeScreen({super.key});
  @override
  State<HomeScreen> createState()=>_HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

TextEditingController _controller=TextEditingController();
void _analyzeText() async{
    String input=_controller.text.trim();

    if(input.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Enter Some Text")));
      return;
    }

    showDialog(context: context, 
    barrierDismissible: false,
     builder: (_)=>const Center(child: CircularProgressIndicator(),));

     String result = await AIService.analyzeText(input);
     String recommendation = await AIService.getRecommendation(input);
     await saveHistory(input, result);
     print("RAW RESPONSE:\n$result");
     Navigator.pop(context);

   final comparisonData = getComparisonData(input);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ResultScreen(
      result: result,
      recommendation: recommendation,
      showAlert: comparisonData["score"] > 40,
    ),
  ),
);
}

bool isComparisonTrigger(String text) {
  final keywords = [
    "cracked",
    "placed",
    "earn",
    "salary",
    "package",
    "lpa",
    "faang",
    "internship"
  ];

  text = text.toLowerCase();

  return keywords.any((word) => text.contains(word));
}

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile =
      await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // TEMP: just show file name (OCR later)
    _controller.text = "Image selected: ${pickedFile.name}";
  }
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
     appBar: AppBar(
  title: const Text("RealityCheck AI"),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryScreen(),
          ),
        );
      },
    ),
  ],
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [

              const SizedBox(height: 20,),
              const Text("Analyze social media posts & avoid unhealthy comparison",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16
              ),
              ),

              const SizedBox(height: 30,),

              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Paste LinkedIn / Instagram post here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton.icon(
  onPressed: _pickImage,
  icon: const Icon(Icons.image),
  label: const Text("Upload Screenshot"),
),

 const SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: _analyzeText, child: const Text("Analyze",
                style: TextStyle(fontSize: 18),)
                ),
              ),

              SizedBox(
                  height: 20,
              ),

             ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DecisionScreen(),
      ),
    );
  },
  child: const Text("Decision Assistant"),
),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgressScreen(),
      ),
    );
  },
  child: const Text("View Progress"),
),
            ],
        ),
      ),
    );
  }
}