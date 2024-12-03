import 'package:flutter/material.dart';
import 'setup_screen.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> answers;

  const SummaryScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.answers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Summary'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    'Quiz Complete!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: $score/$totalQuestions ($percentage%)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                answer['isCorrect']
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: answer['isCorrect']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(answer['question']),
                          const SizedBox(height: 8),
                          Text(
                            'Your Answer: ${answer['userAnswer'].isEmpty ? "Time's up!" : answer['userAnswer']}',
                            style: TextStyle(
                              color: answer['isCorrect']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          if (!answer['isCorrect'])
                            Text(
                              'Correct Answer: ${answer['correctAnswer']}',
                              style: const TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetupScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('New Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}