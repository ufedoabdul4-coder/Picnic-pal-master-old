import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Already imported, but good to note
import 'recording_bar.dart';
import 'venue_model.dart' as venue_model;
import 'plan_picnic_screen.dart' show partyCategories;
import 'event_provider.dart';

class ChatSession {
  final String id;
  String title;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  ChatSession({required this.id, required this.title, required this.timestamp, required this.messages});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      messages: (json['messages'] as List).map((m) => ChatMessage.fromJson(m)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }
}

class ChatbotScreen extends StatefulWidget {
  final ChatSession? initialSession;
  const ChatbotScreen({super.key, this.initialSession});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isLoading = false;
  bool _isRecording = false;

  // IMPORTANT: Replace with your actual API key.
  // For production apps, it's crucial to store this key securely on a backend server,
  // not directly in the app. We use --dart-define for better security in development.
 static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();
    ApiClient.setupApiToken(); // For transcription backend

    if (widget.initialSession != null) {
      _currentSession = widget.initialSession;
    } else {
      // Start a new session if none is provided
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentSession = ChatSession(
          id: sessionId,
          title: "New Chat",
          timestamp: DateTime.now(),
messages: [ChatMessage(text: "Hi! I'm your Quivvo AI. 🤖\nHow can I help you plan your event today?", isUser: false)]);
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _saveCurrentSession(); // Auto-save the chat when the screen is left
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _currentSession?.messages.insert(0, message);
    });
    _scrollToBottom();
  }

  Future<void> _saveCurrentSession() async {
    // Don't save if the chat is empty or just the initial bot message
    if (_currentSession == null || _currentSession!.messages.length <= 1) {
      return;
    }

    // Update the timestamp before saving
    _currentSession = ChatSession(
      id: _currentSession!.id,
      title: _currentSession!.title,
      messages: _currentSession!.messages,
      timestamp: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString('chat_history');
    List<ChatSession> sessions = [];

    if (sessionsString != null) {
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      sessions = sessionsJson.map((json) => ChatSession.fromJson(json)).toList();
    }

    // Check if the current session already exists to update it, otherwise add it as new
    final existingIndex = sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (existingIndex != -1) {
      sessions[existingIndex] = _currentSession!; // Update existing
    } else {
      sessions.add(_currentSession!); // Add new
    }

    await prefs.setString('chat_history', jsonEncode(sessions.map((s) => s.toJson()).toList()));
  }

  void _addBotMessage(String text) {
    _addMessage(ChatMessage(text: text, isUser: false));
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              AppBar( // The title will now show the session title
title: Text('Quivvo AI', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                backgroundColor: theme.scaffoldBackgroundColor,
                centerTitle: true,
                elevation: 0,
                iconTheme: IconThemeData(color: theme.colorScheme.primary),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: 'Recent Chats',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentChatsScreen()));
                    },
                  ),
                ],
              ),
              Expanded( // The list view now builds from the current session's messages
                child: ListView.builder(
                  controller: _chatScrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    return _buildChatMessageBubble(message);
                  },
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
Text("Quivvo is thinking...", style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
                    ],
                  ),
                ),
              _buildChatInput(),
            ],
          ),
          // Only build the RecordingBar on supported mobile platforms (Android/iOS)
          // to prevent crashes/errors on web and desktop.
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RecordingBar(
                isVisible: _isRecording,
                onCancel: () => setState(() => _isRecording = false),
                onConfirm: (audioPath) {
                  setState(() => _isRecording = false);
                  _handleTranscription(audioPath);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Aligns buttons to the bottom
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                keyboardType: TextInputType.multiline,
                maxLines: null, // Allows the text field to grow vertically
                minLines: 1, // Starts as a single line
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "e.g., 'Plan a birthday party'",
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(128)),
                  // Adjust padding for a multiline text field
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  border: InputBorder.none,
                ),
                onSubmitted: (text) => _handleUserMessage(text),
              ),
            ),
            // Disable the microphone on platforms where recording is not supported
            // (web, windows, linux, macos).
            if (kIsWeb || !(Platform.isAndroid || Platform.isIOS))
              Tooltip(
                message: "Voice input is not available on this platform.",
                child: Icon(Icons.mic_off, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              )
            else
              IconButton(
                icon: Icon(Icons.mic, color: _isRecording ? theme.colorScheme.primary.withAlpha(150) : theme.colorScheme.primary),
                onPressed: _toggleRecording,
              ),
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: () => _handleUserMessage(_chatController.text),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() => _isRecording = false);
      return;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() => _isRecording = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required to use voice input.')),
      );
    }
  }

  void _saveEventFromAi(String venueName, String partyType, String date) {
    // Find the venue to get its image URL
    venue_model.Venue? venue;
    try {
      venue = venue_model.mockVenues.firstWhere((v) => v.name.toLowerCase() == venueName.toLowerCase());
    } catch (e) { // Catching the error if the venue is not found
      developer.log("AI returned a venue not in the mock list: $venueName");
      // We can still save the event, but without a specific venue image.
    }

    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: partyType,
      date: date, // Assuming AI provides it in a good format
      location: venueName,
      // Use the venue's image if found, otherwise use a consistent fallback.
      // The path is corrected to match the asset paths in venue_model.dart.
      image: venue?.imageUrl ?? 'assets/images/event_picnic.jpg',
    );

    // Use the context to access the provider, which is a safer pattern.
    eventProvider.addEvent(newEvent);
  }

  Future<void> _handleTranscription(String audioPath) async {
    if (audioPath.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Use the ApiClient to handle the transcription call.
      // This keeps your API logic clean and centralized.
      final transcription = await ApiClient.transcribeAudio(audioPath);

      if (transcription.isNotEmpty) {
        _chatController.text = transcription;
        // Optionally, send the message right away
        // _handleUserMessage(transcription);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't recognize speech. Please try again.")),
        );
      }
    } catch (e) {
      developer.log('Transcription Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleUserMessage(String text) {
    if (text.trim().isEmpty) return;

    _addMessage(ChatMessage(text: text, isUser: true));
    _chatController.clear();
    _scrollToBottom(); // Ensure the UI scrolls after adding the user's message.

    // --- Web Access Integration ---
    _processUserMessage(text);
  }
  
  List<ChatMessage> get _chatMessages {
    // Helper to safely get messages from the current session
    return _currentSession?.messages ?? [];
  }

  Future<void> _processUserMessage(String text) async {
    setState(() => _isLoading = true);

    if (_apiKey.isEmpty) {
      _addBotMessage("API key not configured. Please add it to your environment variables.");
      setState(() => _isLoading = false);
      return;
    }

    // If this is the first user message, set it as the session title
    if (_currentSession != null && _currentSession!.messages.length <= 2) { // Bot message + first user message
      _currentSession!.title = text;
    }

    // --- Create the detailed prompt for the AI ---
    final venuesList = venue_model.mockVenues.map((v) => "- ${v.name} (Status: ${v.status})").join('\n');
    final partyTypesList = partyCategories.entries.map((e) => "${e.key}:\n  - ${e.value.join('\n  - ')}").join('\n');

    // --- Build Conversation History ---
    // The messages are stored in reverse chronological order (newest first).
    // We need to reverse it back to chronological order for the API.
    // We also skip the very first message, which is the initial greeting from the bot.
    final history = _chatMessages.reversed.toList().sublist(1);
    final conversationContents = history.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'parts': [{'text': msg.text}]
      };
    }).toList();

    // Add the system instructions as the first 'user' message in the history.
    final systemInstructions = """
You are Quivvo, an expert AI event planner. Your goal is to help users plan an event. Your personality should be friendly and helpful.

    **IMPORTANT**: Adapt your tone to match the user's. If they are formal, be formal. If they are casual and use emojis, feel free to be casual and use emojis too.

    Available Venues:
    $venuesList

    Available Party Types:
    $partyTypesList

    Your instructions:
    1.  Engage the user conversationally to gather all necessary details: the chosen venue, the type of party, and the date.
    2.  You MUST use the provided lists for venues and party types. Do not suggest anything outside of these lists.
    3.  If the user is vague, ask clarifying questions until you have all three pieces of information (venue, party type, date).
    4.  Once you have all the details, confirm with the user.
    5.  After confirmation, your FINAL response MUST be ONLY a JSON object with the plan details. Do not add any other text before or after the JSON.

    The JSON format MUST be:z
    ```json
    {
      "plan": {
        "venueName": "Name of the Venue",
        "partyType": "Type of the Party",
        "date": "MMM d, yyyy"
      }
    }
    ```
    """;

    // The final structure to be sent to the API
    final requestContents = [
      {'role': 'user', 'parts': [{'text': systemInstructions}]},
      {'role': 'model', 'parts': [{'text': "Okay, I'm ready to help plan an event!"}]}, // Priming the model
      ...conversationContents, // The actual conversation history
    ];

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': requestContents,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        String botResponse = decodedResponse['candidates'][0]['content']['parts'][0]['text'];

        // Check if the response is the final JSON plan
        botResponse = botResponse.replaceAll("```json", "").replaceAll("```", "").trim();
        try {
          final planJson = jsonDecode(botResponse);
          if (planJson['plan'] != null) {
            final plan = planJson['plan'];
            final String venueName = plan['venueName'];
            final String partyType = plan['partyType'];
            final String date = plan['date'];

            _saveEventFromAi(venueName, partyType, date);
            _addBotMessage("Great! I've saved the event for a '$partyType' at '$venueName' on $date. You can see it in the 'Events' tab.");
          } else {
            // This case handles if the JSON is valid but not in the expected format.
            developer.log("AI returned valid JSON but without a 'plan' key: $botResponse");
            _addBotMessage(botResponse);
          }
        } catch (e) {
          // If it's not valid JSON, treat it as a regular chat message
          _addBotMessage(botResponse);
        }
      } else {
        developer.log('Gemini API Error: ${response.body}');
        _addBotMessage("Sorry, I'm having trouble connecting to the AI. Please try again later.");
      }
    } catch (e) {
      developer.log('Network Error: $e');
      _addBotMessage("Sorry, I couldn't fetch that information. Please check your internet connection and try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class RecentChatsScreen extends StatefulWidget {
  const RecentChatsScreen({super.key});

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  List<ChatSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString('chat_history');
    if (sessionsString != null) {
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      if (mounted) {
        setState(() {
          _sessions = sessionsJson.map((json) => ChatSession.fromJson(json)).toList().reversed.toList();
        });
      }
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _sessions.reversed.toList().map((s) => s.toJson()).toList();
    await prefs.setString('chat_history', jsonEncode(sessionsJson));
  }

  void _startNewChat() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())).then((_) => _loadSessions());
  }

  void _openChat(ChatSession session) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen(initialSession: session))).then((_) => _loadSessions());
  }

  void _deleteChat(ChatSession session) {
    setState(() {
      _sessions.removeWhere((s) => s.id == session.id);
    });
    _saveSessions();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat deleted'), backgroundColor: Colors.redAccent));
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day) {
      return DateFormat.jm().format(timestamp); // e.g., 5:30 PM
    }
    return DateFormat.yMd().format(timestamp); // e.g., 6/10/2024
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('AI Assistant', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: _sessions.isEmpty
          ? Center(child: Text("No recent chats.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Card(
                  color: theme.colorScheme.secondary,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(session.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        Text(_formatTimestamp(session.timestamp), style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.5), fontSize: 12)),
                      ],
                    ),
                    subtitle: Text(session.messages.first.text, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _openChat(session),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8), size: 22),
                      onPressed: () => _deleteChat(session),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        label: const Text('New Chat'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}