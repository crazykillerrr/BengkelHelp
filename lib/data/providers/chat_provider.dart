import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ChatModel> _messages = [];
  bool _isLoading = false;

  List<ChatModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    _isLoading = true;
    notifyListeners();

    try {
      final chatMessage = ChatModel(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('chats').add(chatMessage.toMap());
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ChatModel>> getMessages(String userId1, String userId2) {
    return _firestore
        .collection('chats')
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('chats').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }
}
