import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({
    Key? key,
    required this.questions,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  List<Map<String, dynamic>> _answers = [];
  late Timer _timer;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel();
        if (!_answered) {
          _submitAnswer('');
        }
      }
    });
  }

  void _submitAnswer(String selectedAnswer) {
    _timer.cancel();
    if (_answered) return;

    final question = widget.questions[_currentQuestionIndex];
    final isCorrect = selectedAnswer == question.correctAnswer;
    
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      
      if (isCorrect) {
        _score++;
        _feedbackText = "Correct!";
      } else {
        _feedbackText = selectedAnswer.isEmpty
            ? "Time's up! The correct answer was: ${question.correctAnswer}"
            : "Incorrect. The correct answer was: ${question.correctAnswer}";
      }

      _answers.add({
        'question': question.question,
        'userAnswer': selectedAnswer,
        'correctAnswer': question.correctAnswer,
        'isCorrect': isCorrect,
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
      });
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            score: _score,
            totalQuestions: widget.questions.length,
            answers: _answers,
          ),
        ),
      );
    }
  }

  Widget _buildOptionButton(String option) {
    final bool isSelected = _selectedAnswer == option;
    final bool isCorrect = option == widget.questions[_currentQuestionIndex].correctAnswer;
    
    Color? backgroundColor;
    if (_answered) {
      if (isSelected) {
        backgroundColor = isCorrect ? Colors.green[100] : Colors.red[100];
      } else if (isCorrect) {
        backgroundColor = Colors.green[100];
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(16),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            color: _answered && isCorrect ? Colors.green[900] : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / widget.questions.length,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5 ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Time: $_timeLeft s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ...question.options.map(_buildOptionButton),
              const SizedBox(height: 16),
              if (_answered) ...[
                Text(
                  _feedbackText,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedAnswer == question.correctAnswer
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _currentQuestionIndex < widget.questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}