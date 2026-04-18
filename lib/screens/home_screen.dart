import 'package:flutter/material.dart';
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
   
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                children: [
          
                  const SizedBox(height: 20,),
                  const Text(
            "Understand reality behind social media",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          
               
          
          Align(
            alignment: Alignment.centerLeft,
            child:Row(
          children: [
            Icon(Icons.flash_on, size: 16, color: Colors.indigo),
            const SizedBox(width: 6),
            Text(
        "Try examples",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
            ),
          ],
        ),
          ),
          
          const SizedBox(height: 10),
          
          Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Expanded(child: _exampleChip("Cracked Google in 1 month")),
        const SizedBox(width: 10),
        Expanded(child: _exampleChip("Got 20 LPA after 3 months")),
      ],
    ),
    const SizedBox(height: 10),
    Row(
      children: [
        Expanded(child: _exampleChip("No coding → FAANG job")),
        const SizedBox(width: 10),
        const Spacer(), // keeps alignment clean
      ],
    ),
  ],
),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
              ],
            ),
            child: Column(
              children: [
          TextField(
            cursorColor: const Color(0xFF4F46E5),
            controller: _controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Paste LinkedIn / Instagram post...",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
          
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
          
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4F46E5),
                  width: 2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("Upload Screenshot"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
              ],
            ),
          ),
                
           const SizedBox(height: 24,),
               AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  width: double.infinity,
  height: 55,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    ),
    borderRadius: BorderRadius.circular(14),
  ),
  child: ElevatedButton(
    onPressed: _analyzeText,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    child: const Text(
      "Analyze",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  ),
),
        
            const SizedBox(height: 12),
           Text(
            "We analyze posts to reveal reality, effort, and hidden truth.",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
          
                  SizedBox(
                      height: 20,
                  ),
          
                
          
                ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _exampleChip(String text) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      setState(() {
        _controller.text = text;
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
}