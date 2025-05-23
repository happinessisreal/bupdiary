import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../main.dart'; // Import main.dart to access the global objectbox instance
import '../services/gemini_service.dart'; // Import GeminiService

class EditDiaryEntryScreen extends StatefulWidget {
  final DiaryEntry? diaryEntry;

  const EditDiaryEntryScreen({super.key, this.diaryEntry});

  @override
  State<EditDiaryEntryScreen> createState() => _EditDiaryEntryScreenState();
}

class _EditDiaryEntryScreenState extends State<EditDiaryEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _categoryController;
  late DateTime _selectedDateTime;
  bool _isSaving = false; // To show loading indicator

  // Instance of GeminiService
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diaryEntry?.title ?? '');
    _contentController = TextEditingController(text: widget.diaryEntry?.content ?? '');
    _tagsController = TextEditingController(text: widget.diaryEntry?.tags.join(', ') ?? '');
    _categoryController = TextEditingController(text: widget.diaryEntry?.category ?? '');
    _selectedDateTime = widget.diaryEntry?.dateTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final title = _titleController.text;
      final content = _contentController.text;
      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final category = _categoryController.text;

      // Generate embedding for the content
      final embedding = await _geminiService.generateEmbedding(content);

      final newEntry = DiaryEntry(
        id: widget.diaryEntry?.id ?? 0, // ObjectBox uses 0 for new entries
        title: title,
        content: content,
        dateTime: _selectedDateTime,
        tags: tags,
        category: category,
        embedding: embedding, // Save the embedding
      );

      // Use ObjectBox to save
      objectbox.addDiaryEntry(newEntry);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deleteEntry() async {
    if (widget.diaryEntry != null) {
      // Use ObjectBox to delete
      objectbox.deleteDiaryEntry(widget.diaryEntry!.id);
      if (mounted) {
        Navigator.of(context).pop(); // Pop current screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diaryEntry == null ? 'Add Entry' : 'Edit Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.diaryEntry != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Entry?'),
                    content: const Text('Are you sure you want to delete this diary entry?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmDelete == true) {
                  await _deleteEntry();
                }
              },
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(labelText: 'Content'),
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Date & Time: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                          TextButton(
                            onPressed: _pickDateTime,
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveEntry,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16)),
                          child: Text(widget.diaryEntry == null ? 'Add Entry' : 'Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
