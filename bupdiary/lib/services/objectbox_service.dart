import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as p_provider;
import '../objectbox.g.dart'; // Corrected import path
import '../models/diary_entry.dart';

class ObjectBox {
  late final Store _store;
  late final Box<DiaryEntry> _diaryEntryBox;

  ObjectBox._create(this._store) {
    _diaryEntryBox = Box<DiaryEntry>(_store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "obx-bupdiary"));
    return ObjectBox._create(store);
  }

  // Diary Entry CRUD
  int addDiaryEntry(DiaryEntry entry) => _diaryEntryBox.put(entry);

  DiaryEntry? getDiaryEntry(int id) => _diaryEntryBox.get(id);

  List<DiaryEntry> getAllDiaryEntries() {
    final query = _diaryEntryBox.query().order(DiaryEntry_.dateTime, flags: Order.descending).build();
    final entries = query.find();
    query.close();
    return entries;
  }

  bool deleteDiaryEntry(int id) => _diaryEntryBox.remove(id);

  // Vector Search
  List<DiaryEntry> findSimilarEntries(List<double> queryVector, {int limit = 5}) {
    final query = _diaryEntryBox.query()
        .param(DiaryEntry_.embedding, HnswQueryType.knn)
        .param(HnswFlags.vectorDistanceTypeEuclidean | HnswFlags.debugLogs, 0)
        .param(HnswOptionalParams.ef, 100)
        .param(HnswOptionalParams.efConstruction, 200)
        .param(HnswOptionalParams.sync, true)
        .build();
    query.setQueryVector(DiaryEntry_.embedding, queryVector);
    query.limit = limit;
    final results = query.find();
    query.close();
    return results;
  }

  // Helper to add or update entry with embedding
  Future<void> addOrUpdateDiaryEntryWithEmbedding(DiaryEntry entry, List<double> embedding) async {
    entry.embedding = embedding;
    _diaryEntryBox.put(entry);
  }

  Store get store => _store; // Getter for the store if needed elsewhere
}
