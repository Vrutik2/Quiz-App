import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'https://opentdb.com';

  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api_category.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Category> categories = (data['trivia_categories'] as List)
            .map((category) => Category.fromJson(category))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  static Future<List<Question>> fetchQuestions({
    required int amount,
    required int category,
    required String difficulty,
    required String type,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type'
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] != 0) {
          throw Exception('API returned error code: ${data['response_code']}');
        }
        
        List<Question> questions = (data['results'] as List)
            .map((questionData) => Question.fromJson(questionData))
            .toList();
        
        return questions;
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}