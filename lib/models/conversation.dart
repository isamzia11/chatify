import 'package:chatify/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSnippet {
  final String? id;
  final String? conversationID;
  final String? lastMessage;
  final String? name;
  final String? image;
  final int? unseenCount;
  final Timestamp? timeStamp;

  ConversationSnippet({
    this.conversationID,
    this.id,
    this.lastMessage,
    this.name,
    this.image,
    this.unseenCount,
    this.timeStamp,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>;
    return ConversationSnippet(
      id: _snapshot.id,
      conversationID: _data["conversationID"],
      lastMessage: _data["lastMessage"] != null ? _data["lastMessage"] : "",
      unseenCount: _data["unseenCount"],
      timeStamp: _data["timeStamp"],
      name: _data["name"],
      image: _data["image"],
    );
  }
}

class Conversation {
  final String id;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversation({
    required this.id,
    required this.members,
    required this.messages,
    required this.ownerID,
  });

  factory Conversation.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>;

    // Properly map each message to a Message instance
    List<Message> _parsedMessages =
        (_data["messages"] as List<dynamic>? ?? []).map((dynamic _m) {
          final messageType =
              _m["type"] == "text" ? MessageType.Text : MessageType.Image;
          return Message(
            senerID: _m["senderID"],
            content: _m["content"],
            timestamp: _m["timestamp"],
            type: messageType,
          );
        }).toList();

    return Conversation(
      id: _snapshot.id,
      members: List<String>.from(_data["members"]),
      messages: _parsedMessages,
      ownerID: _data["ownerID"],
    );
  }
}
