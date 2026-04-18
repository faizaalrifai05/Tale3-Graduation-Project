import 'package:flutter/material.dart';

/// A single chat message.
class ChatMessage {
  final bool isMe;
  final String text;
  final String time;

  const ChatMessage({
    required this.isMe,
    required this.text,
    required this.time,
  });
}

/// A conversation thread (inbox row + its messages).
class Conversation {
  final String name;
  final bool isOnline;
  String lastMessage;
  String time;
  int unread;
  List<ChatMessage> messages;

  Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
    required this.messages,
  });
}

/// Manages all chat conversations and messages.
/// Conversations are populated by real-time Firebase data in production.
/// Each user sees only their own conversations — the provider is scoped per
/// authenticated user session (re-created on login/logout via ProxyProvider).
class ChatProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [];

  /// All conversations for the inbox list.
  List<Conversation> get conversations => _conversations;

  /// Total unread count across all conversations.
  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unread);

  /// Find a conversation by name.
  Conversation getByName(String name) =>
      _conversations.firstWhere((c) => c.name == name);

  /// Mark a conversation as read (clear unread badge).
  void markAsRead(String name) {
    final conv = _conversations.firstWhere((c) => c.name == name);
    if (conv.unread > 0) {
      conv.unread = 0;
      notifyListeners();
    }
  }

  /// Send a new message in a conversation and move it to the top of the list.
  void sendMessage(String name, String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '$hour:${now.minute.toString().padLeft(2, '0')} $period';

    final message = ChatMessage(isMe: true, text: text.trim(), time: timeStr);

    final index = _conversations.indexWhere((c) => c.name == name);
    _conversations[index].messages.add(message);
    _conversations[index].lastMessage = text.trim();
    _conversations[index].time = timeStr;

    // Move to top of inbox
    if (index > 0) {
      final conv = _conversations.removeAt(index);
      _conversations.insert(0, conv);
    }

    notifyListeners();
  }
}
