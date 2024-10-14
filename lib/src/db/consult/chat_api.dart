import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String msg;
  final String msgId;
  final String senderId;
  final DateTime createdOn;

  ChatMessage({
    required this.msg,
    required this.msgId,
    required this.senderId,
    required this.createdOn,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      msg: map['msg'],
      msgId: map['msgId'],
      senderId: map['senderId'],
      createdOn: (map['createdOn'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'msg': msg,
      'msgId': msgId,
      'senderId': senderId,
      'createdOn': createdOn,
    };
  }
}

class ChatApi {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Fetch chat messages from a specific chat room
  Future<List<ChatMessage>> fetchChatMessages(String chatDocId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('createdOn', descending: true) // Order by creation time
        .get();

    return snapshot.docs.map(
      (doc) {
        final data = doc.data();
        return ChatMessage.fromMap(data);
      },
    ).toList();
  }

  // Stream<List<ChatMessage>> streamAllChatMessagesForUser(String userId) {
  //   return FirebaseFirestore.instance
  //       .collection('chats')
  //       .where('users', arrayContains: userId)
  //       .snapshots()
  //       .map((snapshot) {
  //     final List<ChatMessage> chatMessages = [];
  //     snapshot.docs.forEach((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final List<dynamic> messages = data['messages'];
  //       messages.forEach((msgData) {
  //         final message = ChatMessage.fromMap(msgData);
  //         chatMessages.add(message);
  //       });
  //     });
  //     return chatMessages;
  //   });
  // }

  // Stream chat messages for real-time updates
  Stream<List<ChatMessage>> streamChatMessages(String chatDocId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('createdOn', descending: true) // Order by creation time
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage.fromMap(data);
      }).toList();
    });
  }

  // Post a chat message to a specific chat room
  Future<void> postChatMessage({
    required String chatDocId,
    required String msg,
    required String senderId,
  }) async {
    final msgId = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .doc()
        .id;

    final chatMessage = ChatMessage(
      msg: msg,
      msgId: msgId,
      senderId: senderId,
      createdOn: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .doc(msgId)
        .set(chatMessage.toMap());
  }
}

// class Chat {
//   final String inboxBody;
//   final DateTime inboxDateTime;
//   final String inboxSenderPhotoUrl;
//   final String inboxType;
//   final String inboxSender;

//   Chat({
//     required this.inboxBody,
//     required this.inboxDateTime,
//     required this.inboxSenderPhotoUrl,
//     required this.inboxType,
//     required this.inboxSender,
//   });
// }

// class InboxAPI {
//   final userId = FirebaseAuth.instance.currentUser!.uid;

//   Future<List<Chat>> fetchInbox() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('consult')
//         .doc(userId)
//         .collection('inbox')
//         .get();

//     return snapshot.docs.map(
//       (doc) {
//         final data = doc.data();
//         return Chat(
//           inboxBody: data['inboxBody'],
//           inboxDateTime: (data['inboxDateTime'] as Timestamp).toDate(),
//           inboxSenderPhotoUrl: data['inboxSenderPhotoUrl'],
//           inboxSender: data['inboxSender'],
//           inboxType: data['inboxType'],
//         );
//       },
//     ).toList();
//   }

//   static Future<String> postInbox(
//       {required String inboxBody,
//       required DateTime inboxDateTime,
//       required String inboxSenderPhotoUrl,
//       required String inboxType,
//       required String inboxSender,
//       required String userIdTo}) async {
//     final inbox = {
//       'inboxBody': inboxBody,
//       'inboxDateTime': inboxDateTime,
//       'inboxSenderPhotoUrl': inboxSenderPhotoUrl,
//       'inboxType': inboxType,
//       'inboxSender': inboxSender,
//       'userIdTo': userIdTo,
//     };

//     await FirebaseFirestore.instance
//         .collection('consult')
//         .doc(userIdTo)
//         .collection('inbox')
//         .add(inbox);

//     return 'SUCCESS';
//   }
// }
