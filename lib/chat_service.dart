import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;
  ChatService._internal();

  final _client = Supabase.instance.client;
  final List<Map<String, dynamic>> _messages = [];
  final Map<String, Apartment> _apartmentCache = {};
  final Map<String, Map<String, dynamic>> _profileCache = {};

  final StreamController<List<Map<String, dynamic>>> _messageController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _conversationController = StreamController.broadcast();

  Stream<List<Map<String, dynamic>>> get messagesStream => _messageController.stream;
  Stream<List<Map<String, dynamic>>> get conversationsStream => _conversationController.stream;

  RealtimeChannel? _channel;
  Timer? _statusTimer;

  Future<void> init() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // 1. Initial Fetch
    await _fetchInitialData(user.id);

    // 2. Setup Single Realtime Channel for Messages
    _channel = _client.channel('global_chat_channel');
    
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) async {
        final record = payload.newRecord;
        final userId = user.id;
        if (record['sender_id'] == userId || record['receiver_id'] == userId) {
          await _handleNewIncomingMessage(record);
        }
      },
    ).subscribe();

    // 3. Simple Last Seen System
    _updateActivity();
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateActivity());
  }

  Future<void> _fetchInitialData(String userId) async {
    try {
      final data = await _client
          .from('messages')
          .select('*, apartments(*), sender:profiles!sender_id(*), receiver:profiles!receiver_id(*)')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: true);

      for (var m in data) {
        _cacheMetadata(m);
        _messages.add(m);
      }
      _notifyListeners();
    } catch (e) {
      debugPrint("ChatService Initial Fetch Error: $e");
    }
  }

  void _cacheMetadata(Map<String, dynamic> message) {
    if (message['apartments'] != null) {
      final apt = Apartment.fromMap(message['apartments']);
      _apartmentCache[apt.id] = apt;
    }
    if (message['sender'] != null) {
      _profileCache[message['sender']['id']] = message['sender'];
    }
    if (message['receiver'] != null) {
      _profileCache[message['receiver']['id']] = message['receiver'];
    }
  }

  Future<void> _handleNewIncomingMessage(Map<String, dynamic> record) async {
    // If metadata is missing in the payload (usually is with basic Postgres changes), fetch once
    if (!_apartmentCache.containsKey(record['apartment_id'])) {
      final aptData = await _client.from('apartments').select().eq('id', record['apartment_id']).single();
      _apartmentCache[record['apartment_id']] = Apartment.fromMap(aptData);
    }
    
    // Avoid duplicates from optimistic updates
    if (!_messages.any((m) => m['id'] == record['id'])) {
      _messages.add(record);
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    _messageController.add(List.unmodifiable(_messages));
    _conversationController.add(_groupMessagesIntoConversations());
  }

  List<Map<String, dynamic>> _groupMessagesIntoConversations() {
    final userId = _client.auth.currentUser?.id;
    final Map<String, Map<String, dynamic>> groups = {};

    // Sort reversed to get latest messages first for the map keys
    for (var m in _messages.reversed) {
      final aptId = m['apartment_id'];
      final otherId = m['sender_id'] == userId ? m['receiver_id'] : m['sender_id'];
      final key = "${aptId}_$otherId";

      if (!groups.containsKey(key)) {
        groups[key] = {
          'apartment': _apartmentCache[aptId],
          'other_user': _profileCache[otherId] ?? {'id': otherId, 'full_name': 'User'},
          'last_message': m['content'],
          'created_at': DateTime.parse(m['created_at']),
        };
      }
    }
    return groups.values.toList()..sort((a, b) => b['created_at'].compareTo(a['created_at']));
  }

  Future<Map<String, dynamic>> sendMessage({
    required String apartmentId,
    required String receiverId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Optimistic addition
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = {
      'id': tempId,
      'sender_id': userId,
      'receiver_id': receiverId,
      'apartment_id': apartmentId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    };

    _messages.add(optimistic);
    _notifyListeners();

    try {
      final response = await _client.from('messages').insert({
        'sender_id': userId,
        'receiver_id': receiverId,

        'apartment_id': apartmentId,
        'content': content,
      }).select().single();

      // Replace optimistic record with real one
      final index = _messages.indexWhere((m) => m['id'] == tempId);
      if (index != -1) _messages[index] = response;
      _notifyListeners();
      return response;
    } catch (e) {
      _messages.removeWhere((m) => m['id'] == tempId);
      _notifyListeners();
      rethrow;
    }
  }

  void _updateActivity() {
    final user = _client.auth.currentUser;
    if (user == null) return;
    _client.from('profiles').update({
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', user.id).then((_) {}, onError: (e) => debugPrint("Activity Update Error: $e"));
  }

  void dispose() {
    _statusTimer?.cancel();
    _channel?.unsubscribe();
    _messageController.close();
    _conversationController.close();
  }
}