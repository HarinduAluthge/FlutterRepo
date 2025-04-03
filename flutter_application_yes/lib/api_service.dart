import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String apiKey = "";
  static const String baseUrl = "https://api.openai.com/v1/chat/completions";

  static Future<List<String>> getTopics(String subject) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': "You are a helpful educational assistant that generates concise, accurate study topics."},
            {'role': 'user', 'content': "Generate 5-8 specific topics for studying $subject. Return only the topic names as a JSON array of strings. For example: [\"Topic 1\", \"Topic 2\"]"},
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseContent = data['choices'][0]['message']['content'];
        
        try {
          final List<dynamic> topics = jsonDecode(responseContent);
          return topics.map((topic) => topic.toString()).toList();
        } catch (e) {
          final String cleanedContent = responseContent
              .replaceAll(RegExp(r'```json|```'), '')
              .trim();
              
          try {
            final List<dynamic> topics = jsonDecode(cleanedContent);
            return topics.map((topic) => topic.toString()).toList();
          } catch (e) {
            final topics = responseContent
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            
            if (topics.isEmpty) {
              throw Exception('Failed to parse topics from response');
            }
            
            return topics;
          }
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting topics: $e');
      throw Exception('Failed to generate topics: $e');
    }
  }

  static Future<String> getTheory(String topic) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': "You are an educational assistant providing detailed explanations of academic topics."},
            {'role': 'user', 'content': "Provide a detailed explanation of $topic. Include key concepts, principles, and applications. Keep it educational and informative."},
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting theory: $e');
      throw Exception('Failed to generate theory: $e');
    }
  }

  static Future<String> getSummary(String topic) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': "You are an educational assistant providing clear, concise summaries of academic topics."},
            {'role': 'user', 'content': "Provide a concise summary of $topic. Focus on the most important concepts and key points. Keep it educational and informative."},
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting summary: $e');
      throw Exception('Failed to generate summary: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMCQs(String topic, {int count = 5}) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': "You are an educational assistant creating multiple choice questions for academic topics."},
            {'role': 'user', 'content': "Create $count multiple choice questions about $topic. Each question should have 4 options with one correct answer. Return as a JSON array where each question has format: {\"question\": \"...\", \"options\": [\"A. ...\", \"B. ...\", \"C. ...\", \"D. ...\"], \"correctAnswer\": \"A\"}"},
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseContent = data['choices'][0]['message']['content'];
        
        try {
          final String cleanedContent = responseContent
              .replaceAll(RegExp(r'```json|```'), '')
              .trim();
              
          final List<dynamic> mcqs = jsonDecode(cleanedContent);
          return mcqs.map((mcq) => mcq as Map<String, dynamic>).toList();
        } catch (e) {
          debugPrint('Error parsing MCQs: $e');
          throw Exception('Failed to parse MCQs from response');
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting MCQs: $e');
      throw Exception('Failed to generate MCQs: $e');
    }
  }

  static Future<List<String>> getSubjectSuggestions(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': "You are an educational assistant helping to suggest relevant academic subjects."},
            {'role': 'user', 'content': "Generate 5 academic subject suggestions based on the search query: '$query'. Return only the subject names as a JSON array of strings."},
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseContent = data['choices'][0]['message']['content'];
        
        try {
          final String cleanedContent = responseContent
              .replaceAll(RegExp(r'```json|```'), '')
              .trim();
              
          final List<dynamic> suggestions = jsonDecode(cleanedContent);
          return suggestions.map((s) => s.toString()).toList();
        } catch (e) {
          try {
            final List<dynamic> suggestions = jsonDecode(responseContent);
            return suggestions.map((s) => s.toString()).toList();
          } catch (e) {
            final suggestions = responseContent
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          
            if (suggestions.isEmpty) {
              throw Exception('Failed to parse suggestions from response');
            }
            
            return suggestions;
          }
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting subject suggestions: $e');
      return [];
    }
  }

  static String _getImagePathForSubject(String subjectName) {
    final lowerSubject = subjectName.toLowerCase();
    
    if (lowerSubject.contains('physics') || lowerSubject.contains('quantum')) {
      return "assets/quantum_mechanics.jpg";
    } else if (lowerSubject.contains('machine') || lowerSubject.contains('computer') || 
               lowerSubject.contains('data') || lowerSubject.contains('artificial')) {
      return "assets/machine_learning.jpg";
    } else {
      return "assets/astronomy.jpg";
    }
  }
}

