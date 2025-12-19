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
        title: const Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChatListItem(
            bengkelName: 'Bengkel Jaya Motor',
            lastMessage: 'Silakan share lokasi ya kak',
            time: '10:30',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 2,
            messages: [
              ChatMessage(text: 'Halo kak 👋', isMe: false),
              ChatMessage(text: 'Selamat datang di Bengkel Jaya Motor', isMe: false),
              ChatMessage(text: 'Motor saya mogok kak', isMe: true),
              ChatMessage(text: 'Motornya apa dan kendalanya bagaimana?', isMe: false),
              ChatMessage(text: 'Beat, tiba-tiba mati', isMe: true),
              ChatMessage(text: 'Silakan share lokasi ya kak 🙏', isMe: false),
            ],
          ),
          ChatListItem(
            bengkelName: 'Bengkel Sumber Rejeki',
            lastMessage: 'Bisa kak, kami OTW',
            time: '09:12',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 0,
            messages: [
              ChatMessage(text: 'Selamat pagi kak 😊', isMe: false),
              ChatMessage(text: 'Bisa servis panggilan?', isMe: true),
              ChatMessage(text: 'Bisa kak 👍', isMe: false),
              ChatMessage(text: 'Lokasi di mana kak?', isMe: false),
              ChatMessage(text: 'Rajabasa kak', isMe: true),
              ChatMessage(text: 'Baik kak, montir kami OTW', isMe: false),
            ],
          ),
          ChatListItem(
            bengkelName: 'Bengkel Maju Jaya',
            lastMessage: 'Estimasi 30 menit ya',
            time: 'Kemarin',
            imageUrl: 'https://i.imgur.com/BoN9kdC.png',
            unreadCount: 1,
            messages: [
              ChatMessage(text: 'Halo kak 👋', isMe: false),
              ChatMessage(text: 'Butuh servis motor?', isMe: false),
              ChatMessage(text: 'Iya kak', isMe: true),
              ChatMessage(text: 'Bisa kami bantu sekarang', isMe: false),
              ChatMessage(text: 'Estimasi 30 menit ya kak', isMe: false),
            ],
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
  final List<ChatMessage> messages;

  const ChatListItem({
    super.key,
    required this.bengkelName,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    required this.unreadCount,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              bengkelName: bengkelName,
              imageUrl: imageUrl,
              messages: messages,
            ),
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
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bengkelName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
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
