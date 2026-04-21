import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Conversation {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  ChatProvider(this._auth);

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    notifyListeners();
  }

  String? get _uid => _auth.currentUser?.uid;
  String get _userName => _auth.userName;

  /// Returns a chat document ID deterministic for any two user IDs.
  static String chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Stream of the current user's conversations, newest first.
  Stream<List<Conversation>> get conversationsStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              final participants =
                  List<String>.from(data['participants'] as List? ?? []);
              final otherUid =
                  participants.firstWhere((p) => p != uid, orElse: () => '');
              final names = Map<String, String>.from(
                  data['participantNames'] as Map? ?? {});
              final unread =
                  Map<String, dynamic>.from(data['unread'] as Map? ?? {});
              return Conversation(
                chatId: doc.id,
                otherUserId: otherUid,
                otherUserName: names[otherUid] ?? 'Unknown',
                lastMessage: data['lastMessage'] as String? ?? '',
                lastMessageTime:
                    (data['lastMessageTime'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                unreadCount: (unread[uid] as num?)?.toInt() ?? 0,
              );
            }).toList());
  }

  /// Stream of messages for a specific chat, oldest first.
  Stream<List<ChatMessage>> messagesStream(String id) {
    return _db
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Send a message. Creates the chat document if it doesn't exist yet.
  Future<void> sendMessage({
    required String otherUserId,
    required String otherUserName,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null || text.trim().isEmpty) return;
    final trimmed = text.trim();
    final id = chatId(uid, otherUserId);
    final chatRef = _db.collection('chats').doc(id);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': uid,
      'text': trimmed,
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.set(chatRef, {
      'participants': [uid, otherUserId],
      'participantNames': {uid: _userName, otherUserId: otherUserName},
      'lastMessage': trimmed,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': uid,
      'unread': {otherUserId: FieldValue.increment(1)},
    }, SetOptions(merge: true));
    await batch.commit();
  }

  /// Clears the unread badge for the current user in a chat.
  Future<void> markAsRead(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('chats').doc(id).update({'unread.$uid': 0});
  }
}
