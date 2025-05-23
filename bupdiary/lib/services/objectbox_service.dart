import 'package:path_provider/path_provider.dart' as p_provider;
import 'package:path/path.dart' as p;
import 'dart:math' as math;
// Direct import for Store, Box etc.
import '../objectbox.g.dart'; // Generated file
import '../models/diary_entry.dart';

class ObjectBoxService { 
  late final Store _store;
  late final Box<DiaryEntry> _diaryEntryBox;

  ObjectBoxService._create(this._store) { 
    _diaryEntryBox = _store.box<DiaryEntry>(); // Correct way to get a Box
  }

  static Future<ObjectBoxService> create() async { 
    final docsDir = await p_provider.getApplicationDocumentsDirectory();
    // openStore is from the generated objectbox.g.dart file
    final store = await openStore(directory: p.join(docsDir.path, "obx-bupdiary"));
    return ObjectBoxService._create(store); 
  }

  // Diary Entry CRUD
  int addDiaryEntry(DiaryEntry entry) => _diaryEntryBox.put(entry);

  DiaryEntry? getDiaryEntry(int id) => _diaryEntryBox.get(id);

  List<DiaryEntry> getAllDiaryEntries() {
    // DiaryEntry_.dateTime and Order.descending are from objectbox.g.dart
    final query = _diaryEntryBox.query().order(DiaryEntry_.dateTime, flags: Order.descending).build();
    final entries = query.find();
    query.close();
    return entries;
  }

  bool deleteDiaryEntry(int id) => _diaryEntryBox.remove(id);

  // Vector Search - Basic implementation without HNSW for now
  List<DiaryEntry> findSimilarEntries(List<double> queryVector, {int limit = 5}) {
    // Get all entries with embeddings
    final query = _diaryEntryBox.query(DiaryEntry_.embedding.notNull()).build();
    final allEntries = query.find();
    query.close();
    
    if (allEntries.isEmpty || queryVector.isEmpty) {
      return [];
    }
    
    // Calculate cosine similarity for each entry
    final entriesWithSimilarity = <({DiaryEntry entry, double similarity})>[];
    
    for (final entry in allEntries) {
      if (entry.embedding != null && entry.embedding!.isNotEmpty) {
        final similarity = _cosineSimilarity(queryVector, entry.embedding!);
        entriesWithSimilarity.add((entry: entry, similarity: similarity));
      }
    }
    
    // Sort by similarity (descending) and take top results
    entriesWithSimilarity.sort((a, b) => b.similarity.compareTo(a.similarity));
    
    return entriesWithSimilarity
        .take(limit)
        .map((item) => item.entry)
        .toList();
  }
  
  // Helper method to calculate cosine similarity between two vectors
  double _cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  // Helper to add or update entry with embedding
  Future<void> addOrUpdateDiaryEntryWithEmbedding(DiaryEntry entry, List<double> embedding) async {
    entry.embedding = embedding;
    _diaryEntryBox.put(entry);
  }

  Store get store => _store; // Getter for the store if needed elsewhere
}
