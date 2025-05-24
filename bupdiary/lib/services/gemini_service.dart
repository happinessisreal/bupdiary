import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/diary_entry.dart';
import '../main.dart'; // Import to access the global objectbox instance

class GeminiService {
  final GenerativeModel _model;
  final GenerativeModel _embeddingModel;

  GeminiService() :
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''
    ),
    _embeddingModel = GenerativeModel(
      model: 'embedding-001', 
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''
    ) {
    if (dotenv.env['GEMINI_API_KEY'] == null || dotenv.env['GEMINI_API_KEY']!.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
  }

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      print('Error generating content: $e');
      return 'Error: Could not generate response.';
    }
  }

  Future<List<double>?> generateEmbedding(String text) async {
    try {
      // Corrected: embedContent now takes a single Content object
      final response = await _embeddingModel.embedContent(Content.text(text));
      // Corrected: response.embedding is no longer nullable directly
      return response.embedding.values;
    } catch (e) {
      print('Error generating embedding: $e');
      return null;
    }
  }

  // This method now uses ObjectBox for finding similar entries.
  Future<List<DiaryEntry>> findSimilarEntries(List<double> embedding, {int topN = 5}) async {
    if (embedding.isEmpty) {
      return [];
    }
    // Use ObjectBox to find similar entries
    return objectbox.findSimilarEntries(embedding, limit: topN);
  }
}
