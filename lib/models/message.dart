import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  late final String senerID;
  late final String content;
  late final Timestamp timestamp;
  late final MessageType type;

  Message({
    required this.senerID,
    required this.content,
    required this.timestamp,
    required this.type,
  });
}
