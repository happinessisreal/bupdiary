import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/diary_entry.dart';
import '../main.dart'; // Import to access the global objectbox instance

class GeminiService {
  static GenerativeModel? _model;
  static GenerativeModel? _embeddingModel;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load API key from environment variable
      const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
      
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY environment variable not set. '
            'Please set it when running: flutter run --dart-define=GEMINI_API_KEY=your_api_key');
      }
      
      _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      _embeddingModel = GenerativeModel(model: 'text-embedding-004', apiKey: apiKey);
      _initialized = true;
      print('Gemini service initialized successfully');
    } catch (e) {
      print('Failed to initialize Gemini service: $e');
      rethrow;
    }
  }

  static Future<String> generateContent(String prompt) async {
    if (!_initialized || _model == null) {
      await initialize();
    }
    
    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      print('Error generating content: $e');
      return 'Sorry, I couldn\'t generate a response. Please try again later.';
    }
  }

  static Future<List<double>?> generateEmbedding(String text) async {
    if (!_initialized || _embeddingModel == null) {
      await initialize();
    }
    
    try {
      final response = await _embeddingModel!.embedContent(Content.text(text));
      return response.embedding.values;
    } catch (e) {
      print('Error generating embedding: $e');
      return null;
    }
  }

  // This method now uses ObjectBox for finding similar entries.
  static Future<List<DiaryEntry>> findSimilarEntries(List<double> embedding, {int topN = 5}) async {
    try {
      if (embedding.isEmpty) {
        return [];
      }
      // Use ObjectBox to find similar entries
      return objectbox.findSimilarEntries(embedding, limit: topN);
    } catch (e) {
      print('Error finding similar entries: $e');
      return [];
    }
  }
}
