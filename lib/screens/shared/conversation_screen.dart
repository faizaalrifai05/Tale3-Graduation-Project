import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/providers/chat_provider.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class ConversationScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ConversationScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late final String _chatId;
  late final Stream<List<ChatMessage>> _messagesStream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    _chatId = ChatProvider.chatId(uid, widget.otherUserId);
    _messagesStream = context.read<ChatProvider>().messagesStream(_chatId);
    // Clear unread badge as soon as the screen opens.
    context.read<ChatProvider>().markAsRead(_chatId);
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<ChatProvider>().sendMessage(
          otherUserId: widget.otherUserId,
          otherUserName: widget.otherUserName,
          text: text,
        );
    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.colors.highlightBackgroundColor,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppStyles.primaryColor),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherUserName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load messages. Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: context.colors.textSecondary, fontSize: 14),
                      ),
                    ),
                  );
                }
                final messages = snapshot.data ?? [];
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUid;
                    return _buildBubble(msg,
                        isMe: isMe,
                        senderInitial: widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : '?');
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.colors.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: context.l10n.typeMessage,
                        hintStyle: TextStyle(
                            color: context.colors.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppStyles.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg,
      {required bool isMe, required String senderInitial}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 13,
              backgroundColor: context.colors.highlightBackgroundColor,
              child: Text(senderInitial,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryColor)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppStyles.primaryColor
                        : context.colors.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: context.colors.borderColor),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : context.colors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_formatTime(msg.timestamp),
                    style: TextStyle(
                        color: context.colors.textTertiary, fontSize: 10)),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 13,
              backgroundColor: context.colors.highlightBackgroundColor,
              child: Icon(Icons.person,
                  size: 14, color: AppStyles.primaryColor),
            ),
          ],
        ],
      ),
    );
  }
}
