import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../models/diary_entry.dart'; // For type hinting

// Define a simple class for chat messages
class ChatMessage {
  final String text;
  final bool isUserMessage;
  ChatMessage({required this.text, required this.isUserMessage});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUserMessage: true));
      _isLoading = true;
    });

    try {
      // 1. Generate embedding for the user's query
      final queryEmbedding = await _geminiService.generateEmbedding(text);

      List<DiaryEntry> relevantEntries = [];
      if (queryEmbedding != null && queryEmbedding.isNotEmpty) {
        // 2. Find similar diary entries
        relevantEntries = await _geminiService.findSimilarEntries(queryEmbedding);
      }

      // 3. Construct the prompt for Gemini
      String context = relevantEntries.map((e) => "Title: ${e.title}\nContent: ${e.content}").join("\n\n---\n\n");
      String prompt = "You are a helpful University Diary Assistant. "
          "Answer the user's question based primarily on the following diary entries. "
          "If the diary entries don't provide a relevant answer, say that you couldn't find anything in the diary. "
          "User Question: $text\n\n"
          "Relevant Diary Entries:\n$context";

      if (relevantEntries.isEmpty) {
        prompt = "You are a helpful University Diary Assistant. "
            "The user asked: '$text'. "
            "There were no specific diary entries found related to this. You can try to answer generally or state that no specific diary information was found.";
      }

      // 4. Get response from Gemini
      final String response = await _geminiService.generateContent(prompt);

      setState(() {
        _messages.add(ChatMessage(text: response, isUserMessage: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error: Could not get a response. $e", isUserMessage: false));
      });
      print("Error in chat: $e");
    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Assistant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // To show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (_, int index) {
                final message = _messages[_messages.length - 1 - index]; // Show in reverse
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: message.isUserMessage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                    color: message.isUserMessage
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoading ? null : _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
