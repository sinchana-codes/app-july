import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

// STATELESS WIDGET
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

// WELCOME SCREEN
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Quiz App"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Smart Quiz App",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Test your knowledge with 10 questions!",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizScreen(),
                    ),
                  );
                },
                child: const Text("Start Quiz"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// QUESTIONS
List questions = [
  [
    "Capital of India?",
    ["Delhi", "Mumbai", "Chennai", "Kolkata"],
    "Delhi"
  ],
  [
    "Flutter uses which language?",
    ["Dart", "Java", "Python", "C++"],
    "Dart"
  ],
  [
    "Who developed Flutter?",
    ["Google", "Apple", "Microsoft", "Amazon"],
    "Google"
  ],
  [
    "Which keyword creates a constant in Dart?",
    ["var", "const", "let", "new"],
    "const"
  ],
  [
    "Which widget can change its state?",
    ["Text", "Row", "StatefulWidget", "Icon"],
    "StatefulWidget"
  ],
  [
    "Which function updates the UI?",
    ["setState()", "main()", "build()", "runApp()"],
    "setState()"
  ],
  [
    "Which widget provides the basic screen structure?",
    ["Scaffold", "Text", "Row", "Icon"],
    "Scaffold"
  ],
  [
    "Which widget arranges items vertically?",
    ["Row", "Column", "Stack", "Center"],
    "Column"
  ],
  [
    "Which widget displays text?",
    ["Text", "Image", "Icon", "Row"],
    "Text"
  ],
  [
    "Which method is used for navigation?",
    ["Navigator.push()", "open()", "start()", "go()"],
    "Navigator.push()"
  ],
];

// QUIZ SCREEN
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int q = 0;
  int score = 0;
  String selected = "";

  void next() {
    if (selected == "") {
      return;
    }

    if (selected == questions[q][2]) {
      score++;
    }

    if (q < 9) {
      setState(() {
        q++;
        selected = "";
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${q + 1}/10"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              questions[q][0],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            ...questions[q][1].map<Widget>(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selected = option;
                      });
                    },

                    child: Text(option),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: next,
              child: Text(
                q == 9 ? "Finish" : "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RESULT SCREEN
class ResultScreen extends StatelessWidget {
  final int score;

  const ResultScreen(this.score, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "Quiz Completed!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Your Score: $score / 10",
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
