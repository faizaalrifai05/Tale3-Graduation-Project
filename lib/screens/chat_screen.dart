import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 48, left: 20, right: 8, bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Messages',
                  style: TextStyle(
                    color: AppStyles.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: AppStyles.textPrimary, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppStyles.textPrimary, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppStyles.borderColor),

        // Chat history
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildMessageBubble(
                isMe: false,
                text: 'I\'ve arrived at the designated pickup zone near the fountain.',
                time: '10:12 AM',
              ),
              _buildMessageBubble(
                isMe: true,
                text: 'Great, I\'m just finishing up. See you at the main gate in 2 minutes!',
                time: '10:13 AM',
              ),
              _buildMessageBubble(
                isMe: false,
                text: 'Perfect. I\'m driving a white Toyota Camry, plate number ABC-1234.',
                time: '10:13 AM',
              ),
              _buildMessageBubble(
                isMe: false,
                text: 'I\'ll have my hazard lights on so you can spot me easily.',
                time: '10:14 AM',
              ),
              _buildMessageBubble(
                isMe: true,
                text: 'Got it. Just stepped out of the building. Walking towards the gate now.',
                time: '10:15 AM',
              ),
            ],
          ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppStyles.cardBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppStyles.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppStyles.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppStyles.textTertiary, fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(Icons.emoji_emotions_outlined, color: AppStyles.textTertiary, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppStyles.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({required bool isMe, required String text, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppStyles.primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe ? null : Border.all(color: AppStyles.borderColor),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppStyles.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: AppStyles.textTertiary, fontSize: 10)),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

