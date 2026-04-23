import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart';
import 'chat_service.dart';

class AgentChatScreen extends StatefulWidget {
  final Apartment apartment;
  final String managerName;
  final String? otherUserId;

  const AgentChatScreen({
    super.key,
    required this.apartment,
    required this.managerName,
    this.otherUserId,
  });

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? _currentUser = Supabase.instance.client.auth.currentUser;
  late final String _targetUserId;
  DateTime? _targetLastSeen;

  @override
  void initState() {
    super.initState();
    // If otherUserId is passed, we are the manager talking to a client.
    // Otherwise, we are the client talking to the manager.
    _targetUserId = widget.otherUserId ?? widget.apartment.managerId;
    
    ChatService.instance.init(); // Ensure service is running
    _loadTargetProfile();
  }

  Future<void> _loadTargetProfile() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('last_seen')
          .eq('id', _targetUserId)
          .maybeSingle();
      if (data != null && data['last_seen'] != null) {
        setState(() {
          _targetLastSeen = DateTime.parse(data['last_seen']);
        });
      }
    } catch (e) {
      debugPrint("Error loading target profile: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;
    _messageController.clear();
    try {
      await ChatService.instance.sendMessage(
        apartmentId: widget.apartment.id,
        receiverId: _targetUserId,
        content: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending message: $e")),
        );
      }
    }
  }

  String _formatLastSeen() {
    if (_targetLastSeen == null) return "Offline";
    final difference = DateTime.now().difference(_targetLastSeen!);
    if (difference.inMinutes < 2) return "Online";
    
    if (difference.inDays == 0) {
      return "Last seen at ${DateFormat.jm().format(_targetLastSeen!)}";
    } else if (difference.inDays == 1) {
      return "Last seen yesterday";
    } else {
      return "Last seen ${DateFormat.yMMMd().format(_targetLastSeen!)}";
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.managerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  _formatLastSeen(),
                  style: TextStyle(
                    fontSize: 10, 
                    color: _formatLastSeen() == "Online" ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            Text(widget.apartment.title, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService.instance.messagesStream,
              initialData: ChatService.instance.currentMessages,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading messages"));
                if (!snapshot.hasData || (snapshot.connectionState == ConnectionState.waiting && snapshot.data!.isEmpty)) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter messages to only show the conversation between current user and the target user
                // Trigger scroll to bottom on new data
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                  ChatService.instance.markAsRead(
                    apartmentId: widget.apartment.id,
                    otherUserId: _targetUserId,
                  );
                });

                final allMessages = snapshot.data!;
                final messages = allMessages.where((msg) {
                  final senderId = msg['sender_id'];
                  final receiverId = msg['receiver_id'];
                  final currentId = _currentUser?.id;
                  return msg['apartment_id'] == widget.apartment.id && 
                         ((senderId == currentId && receiverId == _targetUserId) ||
                         (senderId == _targetUserId && receiverId == currentId));
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == _currentUser?.id;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? theme.colorScheme.primary : theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}