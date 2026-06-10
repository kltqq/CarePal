import 'package:flutter/material.dart';
import 'package:flutter_application_11/chatbot_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];

  bool isLoading = false;

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      isLoading = true;
    });

    _controller.clear();

    try {
      final reply = await ChatBotService.sendMessage(text);

      if (!mounted) return;
      setState(() {
        messages.add({'sender': 'bot', 'text': reply});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add({'sender': 'bot', 'text': 'Error connecting to server'});
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Widget bubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return bubble(msg['text']!, msg['sender'] == 'user');
              },
            ),
          ),

          if (isLoading)
            const Padding(padding: EdgeInsets.all(8), child: Text("Typing...")),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask something...',
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
