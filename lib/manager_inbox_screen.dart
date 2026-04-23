import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart';
import 'agent_chat_screen.dart';
import 'chat_service.dart' as chatService;

class ManagerInboxScreen extends StatefulWidget {
  const ManagerInboxScreen({super.key});

  @override
  State<ManagerInboxScreen> createState() => _ManagerInboxScreenState();
}

class _ManagerInboxScreenState extends State<ManagerInboxScreen> {
  final User? _currentUser = Supabase.instance.client.auth.currentUser;
  @override
  void initState() {
    super.initState();
    chatService.ChatService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentUser == null) {
      return Scaffold(body: Center(child: Text("Please login to see messages")));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inquiries', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.ChatService.instance.conversationsStream,
        initialData: chatService.ChatService.instance.currentConversations,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Error loading conversations: ${snapshot.error}"),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!;

          if (conversations.isEmpty) {
            return Center(
              child: Text("No messages yet", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final apartment = conv['apartment'] as Apartment;
              final otherUser = conv['other_user'];
              final lastMessage = conv['last_message'];
              final unreadCount = conv['unread_count'] as int;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: otherUser['avatar_url'] != null ? NetworkImage(otherUser['avatar_url']) : null,
                  child: otherUser['avatar_url'] == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                title: Text(otherUser['full_name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Re: ${apartment.title}", style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                    Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                        child: Text(unreadCount.toString(),
                            style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right, color: theme.colorScheme.primary, size: 20),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgentChatScreen(
                        apartment: apartment,
                        managerName: otherUser['full_name'] ?? "User",
                        otherUserId: otherUser['id'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}