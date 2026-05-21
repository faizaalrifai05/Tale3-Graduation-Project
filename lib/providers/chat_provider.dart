import 'dart:async';
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

  ChatProvider(this._auth) {
    _restartConversationsListener();
  }

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    _restartConversationsListener();
    notifyListeners();
  }

  @override
  void dispose() {
    _convSub?.cancel();
    _convController.close();
    _unreadController.close();
    super.dispose();
  }

  // ── Conversations stream (persistent, auth-aware) ─────────────────────────

  final _convController = StreamController<List<Conversation>>.broadcast();
  final _unreadController = StreamController<int>.broadcast();
  StreamSubscription<QuerySnapshot>? _convSub;
  List<Conversation> _lastConversations = const [];
  int _lastTotalUnread = 0;

  Stream<List<Conversation>> get conversationsStream {
    final ctrl = StreamController<List<Conversation>>();
    ctrl.add(_lastConversations);
    final sub = _convController.stream.listen(ctrl.add, onError: ctrl.addError, onDone: ctrl.close);
    ctrl.onCancel = sub.cancel;
    return ctrl.stream;
  }

  Stream<int> get totalUnreadStream {
    final ctrl = StreamController<int>();
    ctrl.add(_lastTotalUnread);
    final sub = _unreadController.stream.listen(ctrl.add, onError: ctrl.addError, onDone: ctrl.close);
    ctrl.onCancel = sub.cancel;
    return ctrl.stream;
  }

  List<Conversation> get lastConversations => List.unmodifiable(_lastConversations);

  void _restartConversationsListener() {
    _convSub?.cancel();
    final uid = _uid;
    if (uid == null) return;
    _convSub = _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen(
      (snap) {
        final docs = snap.docs.toList()
          ..sort((a, b) {
            final aTime = (a.data()['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime = (b.data()['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
        final convs = docs.map((doc) {
          final data = doc.data();
          final participants = List<String>.from(data['participants'] as List? ?? []);
          final otherUid = participants.firstWhere((p) => p != uid, orElse: () => '');
          final names = Map<String, String>.from(data['participantNames'] as Map? ?? {});
          final unread = Map<String, dynamic>.from(data['unread'] as Map? ?? {});
          return Conversation(
            chatId: doc.id,
            otherUserId: otherUid,
            otherUserName: names[otherUid] ?? 'Unknown',
            lastMessage: data['lastMessage'] as String? ?? '',
            lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
            unreadCount: (unread[uid] as num?)?.toInt() ?? 0,
          );
        }).toList();

        _lastConversations = convs;
        if (!_convController.isClosed) _convController.add(convs);
        final totalUnread = convs.fold<int>(0, (sum, c) => sum + c.unreadCount);
        _lastTotalUnread = totalUnread;
        if (!_unreadController.isClosed) _unreadController.add(totalUnread);
      },
      onError: (e) => debugPrint('conversations stream error: $e'),
    );
  }

  String? get _uid => _auth.currentUser?.uid;
  String get _userName => _auth.userName;

  /// Returns a chat document ID deterministic for any two user IDs.
  static String chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }


  /// Stream of messages for a specific chat, oldest first.
  /// Sorted client-side — avoids Firestore index requirements and includes
  /// optimistic local writes whose serverTimestamp is still pending.
  Stream<List<ChatMessage>> messagesStream(String id) {
    return _db
        .collection('chats')
        .doc(id)
        .collection('messages')
        .snapshots()
        .map((snap) {
          final msgs = snap.docs.map(ChatMessage.fromDoc).toList();
          msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return msgs;
        });
  }

  /// Send a message. Creates the chat document first if it doesn't exist,
  /// then writes the message in a separate batch so the message rule's
  /// get(chats/chatId) call finds an existing document.
  /// Returns null on success, error string on failure.
  Future<String?> sendMessage({
    required String otherUserId,
    required String otherUserName,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null) return 'Not logged in.';
    if (text.trim().isEmpty) return null;
    final trimmed = text.trim();
    final id = chatId(uid, otherUserId);
    final chatRef = _db.collection('chats').doc(id);

    try {
      final chatSnap = await chatRef.get();
      if (!chatSnap.exists) {
        await chatRef.set({
          'participants': [uid, otherUserId],
          'participantNames': {uid: _userName, otherUserId: otherUserName},
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastSenderId': '',
          'unread': {uid: 0, otherUserId: 0},
        });
      }

      final msgRef = chatRef.collection('messages').doc();
      final batch = _db.batch();
      batch.set(msgRef, {
        'senderId': uid,
        'text': trimmed,
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.update(chatRef, {
        'participantNames.$uid': _userName,
        'participantNames.$otherUserId': otherUserName,
        'lastMessage': trimmed,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': uid,
        'unread.$otherUserId': FieldValue.increment(1),
        'unread.$uid': 0,
      });
      await batch.commit();
      return null;
    } catch (e) {
      debugPrint('💬 sendMessage ERROR: $e');
      return e.toString();
    }
  }

  /// Ensures the chat document exists so the messages subcollection can be
  /// queried. Called when a conversation screen opens before subscribing to
  /// the messages stream — avoids a permission-denied error caused by the
  /// messages rule doing get(chatDoc) on a non-existent document.
  Future<void> ensureChatExists({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final id = chatId(uid, otherUserId);
    final chatRef = _db.collection('chats').doc(id);
    try {
      final snap = await chatRef.get();
      if (!snap.exists) {
        await chatRef.set({
          'participants': [uid, otherUserId],
          'participantNames': {uid: _userName, otherUserId: otherUserName},
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastSenderId': '',
          'unread': {uid: 0, otherUserId: 0},
        });
      }
    } catch (_) {}
  }

  /// Clears the unread badge for the current user in a chat.
  Future<void> markAsRead(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.collection('chats').doc(id).update({'unread.$uid': 0});
    } catch (_) {}
  }
}
