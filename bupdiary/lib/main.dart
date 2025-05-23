import 'package:flutter/material.dart';
import 'screens/diary_list_screen.dart'; // Import DiaryListScreen
import 'services/objectbox_service.dart'; // Import ObjectBoxService

// Global instance of ObjectBoxService
late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUP Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const DiaryListScreen(), // DiaryListScreen is the home
    );
  }
}
