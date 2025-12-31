import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'consts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final GenerativeModel _model;
  late ChatSession _chatSession;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TASK A: Add system instruction for Chef Bot persona
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: GEMINI_API_KEY,
      systemInstruction: Content.text(
        "You are a professional chef with years of experience in culinary arts. "
        "You only answer questions related to cooking, recipes, ingredients, kitchen techniques, and food. "
        "If someone asks you something unrelated to cooking, politely decline and remind them that you can only help with cooking-related questions. "
        "Be friendly, helpful, and share your culinary expertise."
      ),
    );
    _chatSession = _model.startChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    _textController.clear();

    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null) {
        _showError('Tidak ada respons dari AI');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mending ChatGPT'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // TASK C: Add clear chat button
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                // Restart chat session while preserving the model (and its system instruction)
                _chatSession = _model.startChat();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatSession.history.length,
              itemBuilder: (context, index) {
                final content = _chatSession.history.toList()[index];
                final text = content.parts
                    .whereType<TextPart>()
                    .map<String>((e) => e.text)
                    .join('');

                final isUser = content.role == 'user';

                // TASK B: Add avatars to messages
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar on LEFT for model messages
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple[200],
                          child: const Icon(
                            Icons.smart_toy,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Message bubble
                      Container(
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepPurple[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft:
                                isUser ? Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isUser ? Radius.zero : Radius.circular(12),
                          ),
                        ),
                        child: MarkdownBody(data: text),
                      ),
                      // Avatar on RIGHT for user messages
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tanya sesuatu...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurple,
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
