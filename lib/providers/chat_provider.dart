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
class ChatProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [
    Conversation(
      name: 'Hassan Abdullah',
      lastMessage: 'I\'ll have my hazard lights on so you can spot me easily.',
      time: '10:14 AM',
      unread: 2,
      isOnline: true,
      messages: [
        ChatMessage(isMe: false, text: 'I\'ve arrived at the designated pickup zone near the fountain.', time: '10:12 AM'),
        ChatMessage(isMe: true, text: 'Great, I\'m just finishing up. See you at the main gate in 2 minutes!', time: '10:13 AM'),
        ChatMessage(isMe: false, text: 'Perfect. I\'m driving a white Toyota Camry, plate ABC-1234.', time: '10:13 AM'),
        ChatMessage(isMe: false, text: 'I\'ll have my hazard lights on so you can spot me easily.', time: '10:14 AM'),
      ],
    ),
    Conversation(
      name: 'Sarah T.',
      lastMessage: 'Thanks for the ride, really smooth!',
      time: 'Yesterday',
      unread: 0,
      isOnline: false,
      messages: [
        ChatMessage(isMe: true, text: 'Hi Sarah, I\'m on my way to the pickup point.', time: '3:10 PM'),
        ChatMessage(isMe: false, text: 'Great, thanks! I\'m waiting near the entrance.', time: '3:12 PM'),
        ChatMessage(isMe: true, text: 'Almost there, 2 minutes away.', time: '3:30 PM'),
        ChatMessage(isMe: false, text: 'Thanks for the ride, really smooth!', time: '4:05 PM'),
      ],
    ),
    Conversation(
      name: 'Ali H.',
      lastMessage: 'Are you still at the pickup point?',
      time: 'Yesterday',
      unread: 1,
      isOnline: true,
      messages: [
        ChatMessage(isMe: false, text: 'Hey, are we still on for tomorrow\'s ride?', time: '9:00 AM'),
        ChatMessage(isMe: true, text: 'Yes! Departing at 8 AM from the usual spot.', time: '9:05 AM'),
        ChatMessage(isMe: false, text: 'Are you still at the pickup point?', time: '8:10 AM'),
      ],
    ),
    Conversation(
      name: 'Lina K.',
      lastMessage: 'Great, see you tomorrow morning!',
      time: 'Mon',
      unread: 0,
      isOnline: false,
      messages: [
        ChatMessage(isMe: true, text: 'Hi Lina, I have a ride available tomorrow to Irbid.', time: '6:00 PM'),
        ChatMessage(isMe: false, text: 'That\'s perfect! What time?', time: '6:05 PM'),
        ChatMessage(isMe: true, text: '7:30 AM, pickup from University St.', time: '6:06 PM'),
        ChatMessage(isMe: false, text: 'Great, see you tomorrow morning!', time: '6:08 PM'),
      ],
    ),
    Conversation(
      name: 'Omar S.',
      lastMessage: 'Can I book a seat for Sunday?',
      time: 'Sun',
      unread: 0,
      isOnline: false,
      messages: [
        ChatMessage(isMe: false, text: 'Can I book a seat for Sunday?', time: '11:00 AM'),
      ],
    ),
  ];

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
