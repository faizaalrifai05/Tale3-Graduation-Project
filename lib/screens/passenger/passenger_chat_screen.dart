import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../providers/chat_provider.dart';


class PassengerChatScreen extends StatefulWidget {
  const PassengerChatScreen({super.key});

  @override
  State<PassengerChatScreen> createState() => _PassengerChatScreenState();
}

class _PassengerChatScreenState extends State<PassengerChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    
    // Filter conversations based on search query
    final conversations = chatProvider.conversations.where((conv) {
      if (_searchQuery.isEmpty) return true;
      return conv.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             conv.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // ── Header ──
        Container(
          color: context.colors.surfaceColor,
          padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Messages',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_outlined,
                    color: context.colors.textPrimary, size: 20),
              ),
            ],
          ),
        ),

        // ── Search bar ──
        Container(
          color: context.colors.surfaceColor,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.colors.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search conversations\u2026',
                hintStyle:
                    TextStyle(color: context.colors.textTertiary, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: context.colors.textTertiary, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        Divider(height: 1, color: context.colors.borderColor),

        // ── Conversation list ──
        Expanded(
          child: conversations.isEmpty 
          ? Center(
              child: Text(
                'No conversations found.',
                style: TextStyle(color: context.colors.textTertiary, fontSize: 15),
              ),
            )
          : ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, indent: 76, color: context.colors.borderColor),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationTile(
                conversation: conv,
                onTap: () {
                  // Clear unread via provider
                  context.read<ChatProvider>().markAsRead(conv.name);
                  // Navigate to conversation
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ConversationScreen(conversationName: conv.name),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONVERSATION TILE  (one row in the inbox)
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unread > 0;

    return Material(
      color: context.colors.surfaceColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar + online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: context.colors.highlightBackgroundColor,
                    child: Text(
                      conversation.name[0],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppStyles.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.surfaceColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Name + last message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Time + unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    conversation.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUnread
                          ? AppStyles.primaryColor
                          : context.colors.textTertiary,
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        conversation.unread.toString(),
                        style: TextStyle(
                            color: AppStyles.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONVERSATION SCREEN  (the actual chat messages)
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationScreen extends StatefulWidget {
  final String conversationName;

  const _ConversationScreen({required this.conversationName});

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _showCallDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Call $name', style: TextStyle(fontWeight: FontWeight.w800, color: ctx.colors.textPrimary)),
        content: Text(
          'In-app calling is coming soon.\nYou can contact $name via the chat.',
          style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: ctx.colors.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
            _optionTile(ctx, Icons.person_outline, 'View Profile', () => Navigator.pop(ctx)),
            _optionTile(ctx, Icons.delete_outline, 'Clear Chat', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Chat with $name cleared'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }),
            _optionTile(ctx, Icons.block, 'Block User', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$name has been blocked'),
                backgroundColor: AppStyles.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }),
            _optionTile(ctx, Icons.flag_outlined, 'Report', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Report submitted for $name'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: ctx.colors.textPrimary, size: 22),
      title: Text(label, style: TextStyle(fontSize: 15, color: ctx.colors.textPrimary)),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(widget.conversationName, text);
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so UI rebuilds when a message is sent
    final conv = context.watch<ChatProvider>().getByName(widget.conversationName);

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.highlightBackgroundColor,
                  child: Text(
                    conv.name[0],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppStyles.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.surfaceColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  conv.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: conv.isOnline
                        ? AppStyles.successColor
                        : context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone_outlined,
                color: context.colors.textPrimary, size: 22),
            onPressed: () => _showCallDialog(context, conv.name),
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: context.colors.textPrimary, size: 22),
            onPressed: () => _showMoreOptions(context, conv.name),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(conv.messages[index], conv.name);
              },
            ),
          ),

          // ── Input bar ──
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.attach_file,
                      color: context.colors.textSecondary, size: 20),
                ),
                const SizedBox(width: 10),
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
                        hintText: 'Type a message\u2026',
                        hintStyle: TextStyle(
                            color: context.colors.textTertiary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send,
                        color: AppStyles.onPrimary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg, String senderName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            CircleAvatar(
              radius: 13,
              backgroundColor: context.colors.highlightBackgroundColor,
              child: Text(
                senderName[0],
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isMe ? AppStyles.primaryColor : context.colors.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                    ),
                    border: msg.isMe
                        ? null
                        : Border.all(color: context.colors.borderColor),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isMe ? AppStyles.onPrimary : context.colors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: TextStyle(
                      color: context.colors.textTertiary, fontSize: 10),
                ),
              ],
            ),
          ),
          if (msg.isMe) ...[
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
