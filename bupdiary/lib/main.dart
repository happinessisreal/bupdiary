import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/diary_list_screen.dart'; // Import DiaryListScreen
import 'services/objectbox_service.dart'; // Import ObjectBoxService

// Global instance of ObjectBoxService
late ObjectBoxService objectbox; // Changed from ObjectBox to ObjectBoxService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  objectbox = await ObjectBoxService.create(); // Changed from ObjectBox to ObjectBoxService
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
