import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ChatListItem(
            bengkelName: 'Bengkel Jaya Motor',
            lastMessage: 'Silakan share lokasi ya kak',
            time: '10:30',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 2,
          ),
          ChatListItem(
            bengkelName: 'Bengkel Sumber Rejeki',
            lastMessage: 'Bisa kak, kami OTW',
            time: '09:12',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 0,
          ),
          ChatListItem(
            bengkelName: 'Bengkel Maju Jaya',
            lastMessage: 'Estimasi 30 menit ya',
            time: 'Kemarin',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 1,
          ),
        ],
      ),
    );
  }
}

/* ================= CHAT LIST ITEM ================= */

class ChatListItem extends StatelessWidget {
  final String bengkelName;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final int unreadCount;

  const ChatListItem({
    super.key,
    required this.bengkelName,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DummyChatScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(imageUrl),
            ),

            const SizedBox(width: 14),

            // Name & Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bengkelName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Time & Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
