import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Inbox {
  Map<String, String> inboxBody; // Modified to hold bilingual content
  final DateTime inboxDateTime;
  final String inboxSenderPhotoUrl;
  String inboxType;
  final String inboxSender;
  final String inboxSenderId;
  DateTime? consultDate;
  final String inboxId;
  int? rescheduleCount;

  Inbox({
    required this.inboxBody,
    required this.inboxDateTime,
    required this.inboxSenderPhotoUrl,
    required this.inboxType,
    required this.inboxSender,
    required this.inboxSenderId,
    this.consultDate,
    required this.inboxId,
    this.rescheduleCount,
  });
}

class InboxAPI {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Inbox>> fetchInbox() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('consult')
        .doc(userId)
        .collection('inbox')
        .get();

    return snapshot.docs.map(
      (doc) {
        final data = doc.data();
        return Inbox(
          inboxBody: {
            'id': data['inboxBody']['id'],
            'en': data['inboxBody']['en']
          },
          inboxDateTime: (data['inboxDateTime'] as Timestamp).toDate(),
          inboxSenderPhotoUrl: data['inboxSenderPhotoUrl'],
          inboxSender: data['inboxSender'],
          inboxSenderId: data['inboxSenderId'],
          inboxType: data['inboxType'],
          consultDate: data['consultDate'] != null
              ? (data['consultDate'] as Timestamp).toDate()
              : null,
          inboxId: data['inboxId'],
          rescheduleCount: data['rescheduleCount'],
        );
      },
    ).toList();
  }

  static Future<String> postInbox({
    required Map<String, String>
        inboxBody, // Modified to accept bilingual content
    required DateTime inboxDateTime,
    required String inboxSenderPhotoUrl,
    required String inboxType,
    required String inboxSender,
    required String inboxSenderId,
    required String userIdTo,
    DateTime? consultDate,
  }) async {
    final inboxId = FirebaseFirestore.instance
        .collection('consult')
        .doc(userIdTo)
        .collection('inbox')
        .doc()
        .id;
    final inbox = {
      'inboxBody': inboxBody,
      'inboxDateTime': inboxDateTime,
      'inboxSenderPhotoUrl': inboxSenderPhotoUrl,
      'inboxType': inboxType,
      'inboxSender': inboxSender,
      'inboxSenderId': inboxSenderId,
      'userIdTo': userIdTo,
      'consultDate': consultDate,
      'inboxId': inboxId,
      'rescheduleCount': (inboxType == 'request') ? 0 : null,
    };

    final chatDocRef =
        FirebaseFirestore.instance.collection('consult').doc(userIdTo);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatDocRef);
      if (chatDoc.exists) {
        transaction.update(chatDocRef, {
          'notSeenInbox': FieldValue.increment(1),
        });
      } else {
        transaction.set(chatDocRef, {
          'notSeenInbox': 1,
        });
      }
    });

    await FirebaseFirestore.instance
        .collection('consult')
        .doc(userIdTo)
        .collection('inbox')
        .doc(inboxId)
        .set(inbox);

    return 'SUCCESS';
  }

  static Future<String> sendReschedule({
    required Map<String, String>
        inboxBody, // Modified to accept bilingual content
    required DateTime inboxDateTime,
    required String inboxSenderPhotoUrl,
    required String inboxType,
    required String inboxSender,
    required String inboxSenderId,
    required String userIdTo,
    DateTime? consultDate,
    required int rescheduleCount,
  }) async {
    final inboxId = FirebaseFirestore.instance
        .collection('consult')
        .doc(userIdTo)
        .collection('inbox')
        .doc()
        .id;
    final inbox = {
      'inboxBody': inboxBody,
      'inboxDateTime': inboxDateTime,
      'inboxSenderPhotoUrl': inboxSenderPhotoUrl,
      'inboxType': inboxType,
      'inboxSender': inboxSender,
      'inboxSenderId': inboxSenderId,
      'userIdTo': userIdTo,
      'consultDate': consultDate,
      'inboxId': inboxId,
      'rescheduleCount': rescheduleCount + 1,
    };

    final chatDocRef =
        FirebaseFirestore.instance.collection('consult').doc(userIdTo);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatDocRef);
      if (chatDoc.exists) {
        transaction.update(chatDocRef, {
          'notSeenInbox': FieldValue.increment(1),
        });
      } else {
        transaction.set(chatDocRef, {
          'notSeenInbox': 1,
        });
      }
    });

    await FirebaseFirestore.instance
        .collection('consult')
        .doc(userIdTo)
        .collection('inbox')
        .doc(inboxId)
        .set(inbox);

    return 'SUCCESS';
  }
}
