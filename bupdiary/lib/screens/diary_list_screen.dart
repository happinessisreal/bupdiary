import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../main.dart'; // Import main.dart to access the global objectbox instance
import 'edit_diary_entry_screen.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _refreshDiaryEntries();
  }

  void _refreshDiaryEntries() {
    setState(() {
      _diaryEntries = objectbox.getAllDiaryEntries(); // New way with ObjectBox
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat Assistant',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _diaryEntries.isEmpty
          ? const Center(child: Text('No diary entries yet. Click + to add one!'))
          : ListView.builder(
              itemCount: _diaryEntries.length,
              itemBuilder: (context, index) {
                final entry = _diaryEntries[index];
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(
                    entry.content.length > 100
                        ? '${entry.content.substring(0, 100)}...'
                        : entry.content,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row( // Use a Row to place date and delete button
                    mainAxisSize: MainAxisSize.min, // So the Row doesn't take all available space
                    children: [
                      Text(
                        '${entry.dateTime.day}/${entry.dateTime.month}/${entry.dateTime.year}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[400]),
                        tooltip: 'Delete Entry',
                        onPressed: () => _confirmDelete(context, entry),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditDiaryEntryScreen(diaryEntry: entry),
                      ),
                    );
                    _refreshDiaryEntries(); // Refresh list after editing
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditDiaryEntryScreen()),
          );
          _refreshDiaryEntries(); // Refresh list after adding
        },
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${entry.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                objectbox.deleteDiaryEntry(entry.id);
                _refreshDiaryEntries();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${entry.title}" deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
