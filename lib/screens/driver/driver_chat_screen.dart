import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../providers/chat_provider.dart';
import 'package:testtale3/screens/shared/conversation_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverChatScreen extends StatefulWidget {
  const DriverChatScreen({super.key});

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour:$min $period';
    }
    if (diff.inDays == 1) return 'Yesterday';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

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
                  context.l10n.messages,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: context.l10n.searchConversations,
                hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: context.colors.textTertiary, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        Divider(height: 1, color: context.colors.borderColor),

        // ── Conversation list ──
        Expanded(
          child: StreamBuilder<List<Conversation>>(
            stream: chatProvider.conversationsStream,
            initialData: chatProvider.lastConversations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? [];
              final conversations = _searchQuery.isEmpty
                  ? all
                  : all
                      .where((c) =>
                          c.otherUserName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

              if (conversations.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.noConversations,
                    style: TextStyle(color: context.colors.textTertiary, fontSize: 15),
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => Divider(
                    height: 1, indent: 76, color: context.colors.borderColor),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return _ConversationTile(
                    conversation: conv,
                    timeLabel: _formatTime(conv.lastMessageTime),
                    onTap: () {
                      chatProvider.markAsRead(conv.chatId);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          otherUserId: conv.otherUserId,
                          otherUserName: conv.otherUserName,
                        ),
                      ));
                    },
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
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: context.colors.surfaceColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  conversation.otherUserName.isNotEmpty
                      ? conversation.otherUserName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.otherUserName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
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
                        color: hasUnread ? context.colors.textPrimary : context.colors.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUnread ? AppStyles.primaryColor : context.colors.textTertiary,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
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
