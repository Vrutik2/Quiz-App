import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  int _selectedAmount = 10;
  Category? _selectedCategory;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  void _startQuiz() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      final questions = await ApiService.fetchQuestions(
        amount: _selectedAmount,
        category: _selectedCategory!.id,
        difficulty: _selectedDifficulty,
        type: _selectedType,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(questions: questions),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting quiz: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Number of Questions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Slider(
                            value: _selectedAmount.toDouble(),
                            min: 5,
                            max: 15,
                            divisions: 2,
                            label: _selectedAmount.toString(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAmount = value.round();
                              });
                            },
                          ),
                          Text('Selected: $_selectedAmount questions'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DropdownButton<Category>(
                            isExpanded: true,
                            value: _selectedCategory,
                            hint: const Text('Select Category'),
                            items: _categories.map((Category category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (Category? category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedDifficulty,
                            items: ['easy', 'medium', 'hard']
                                .map((String difficulty) {
                              return DropdownMenuItem<String>(
                                value: difficulty,
                                child: Text(
                                  difficulty[0].toUpperCase() +
                                      difficulty.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? difficulty) {
                              if (difficulty != null) {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Type',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedType,
                            items: [
                              const DropdownMenuItem(
                                value: 'multiple',
                                child: Text('Multiple Choice'),
                              ),
                              const DropdownMenuItem(
                                value: 'boolean',
                                child: Text('True/False'),
                              ),
                            ],
                            onChanged: (String? type) {
                              if (type != null) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}