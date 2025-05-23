import 'package:objectbox/objectbox.dart';

@Entity()
class DiaryEntry {
  @Id()
  int id = 0;

  String title;
  String content;

  @Property(type: PropertyType.date) // Explicitly set PropertyType for DateTime
  DateTime dateTime;

  List<String> tags;
  String category;

  @Property(type: PropertyType.floatVector)
  @HnswIndex(dimensions: 768) // Dimensions for Gemini embedding-001
  List<double>? embedding;

  DiaryEntry({
    this.id = 0,
    required this.title,
    required this.content,
    required this.dateTime,
    required this.tags,
    required this.category,
    this.embedding,
  });
}
