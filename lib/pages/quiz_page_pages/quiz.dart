import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _questions = [];
  Map<String, String> _userAnswers = {};
  bool _isLoading = true;
  bool _isSubmitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      // Fetch all questions from Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('Questions').get();
      List<DocumentSnapshot> documents = querySnapshot.docs;

      // Shuffle and pick 10 random questions
      documents.shuffle();
      List<Map<String, dynamic>> selectedQuestions = documents
          .take(10)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _questions = selectedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitQuiz() {
    int score = 0;
    for (var question in _questions) {
      String correctAnswer = question['answer'];
      String? userAnswer = _userAnswers[question['question']];
      if (userAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      _isSubmitted = true;
      _score = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final questionText = question['question'];
                  final options = question['options'] as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. $questionText',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...options.entries.map((entry) {
                        return RadioListTile<String>(
                          title: Text(entry.value),
                          value: entry.key,
                          groupValue: _userAnswers[questionText],
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[questionText] = value!;
                            });
                          },
                        );
                      }).toList(),
                      SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isSubmitted ? null : _submitQuiz,
              child: Text('Submit'),
            ),
            if (_isSubmitted)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Your score: $_score/${_questions.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
