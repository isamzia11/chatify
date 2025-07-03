import 'package:chatify/models/contact.dart';
import 'package:chatify/models/conversation.dart';
import 'package:chatify/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  static DbService instance = DbService();
  FirebaseFirestore? _db;

  DbService() {
    _db = FirebaseFirestore.instance;
  }

  String _userCollection = 'Users';
  String _converationsCollection = 'Conversations';

  Future<void> createUserInDb(
    String _uid,
    String _name,
    String _email,
    String _imageUrl,
  ) async {
    try {
      return await _db!.collection(_userCollection).doc(_uid).set({
        "name": _name,
        "email": _email,
        "image": _imageUrl,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {}
  }

  Future<void> updateUserLastSeenTime(String _userID) {
    var _ref = _db!.collection(_userCollection).doc(_userID);
    return _ref.update({"lastSeen": Timestamp.now()});
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref = _db!.collection(_converationsCollection).doc(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;

      default:
    }
    return _ref.update({
      "messages": FieldValue.arrayUnion([
        {
          "message": _message.content,
          "senderID": _message.senderID,
          "timestamp": _message.timestamp,
          "type": _messageType,
        },
      ]),
    });
  }

  // In DbService.dart
  // In DbService.dart
  Future<void> createOrGetConversation(
    String currentID,
    String recipientID,
    String recipientName, // This is the name of the recipient (the other user)
    String
    recipientImage, // This is the image of the recipient (the other user)
    Future<void> Function(String conversationID) onSuccess,
  ) async {
    final ref = _db!.collection(_converationsCollection);
    final userConversationRef = _db!
        .collection(_userCollection)
        .doc(currentID)
        .collection(_converationsCollection);

    try {
      final conversationDoc = await userConversationRef.doc(recipientID).get();
      final data = conversationDoc.data();
      final existingConversationID = data?['conversationID'];

      if (existingConversationID != null) {
        await onSuccess(existingConversationID);
      } else {
        final newConversationRef = ref.doc();

        await newConversationRef.set({
          'members': [currentID, recipientID],
          'ownerID': currentID,
          'messages': [],
        });

        final timestamp = Timestamp.now();

        // ✅ Store metadata for current user (correct - shows recipient's info for current user)
        await userConversationRef.doc(recipientID).set({
          'conversationID': newConversationRef.id,
          'lastMessage': '',
          'name':
              recipientName, // This is the name of the person CURRENT_USER is chatting with
          'image':
              recipientImage, // This is the image of the person CURRENT_USER is chatting with
          'type': 'text',
          'timeStamp': timestamp,
          'unseenCount': 0,
        });

        // Get the current user's (sender's) actual profile data
        final senderData =
            await _db!.collection(_userCollection).doc(currentID).get();
        final senderName = senderData.data()?['name'] ?? 'Unknown User';
        final senderImage =
            senderData.data()?['image'] ??
            'https://via.placeholder.com/150'; // Fallback image

        // ✅ Store metadata for recipient (FIXED: should show SENDER'S info for the RECIPIENT)
        await _db!
            .collection(_userCollection)
            .doc(recipientID)
            .collection(_converationsCollection)
            .doc(
              currentID,
            ) // This document is about CURRENT_USER from RECIPIENT'S perspective
            .set({
              'conversationID': newConversationRef.id,
              'lastMessage': '',
              'name':
                  senderName, // <--- CORRECTED: This should be the SENDER'S name (you)
              'image':
                  senderImage, // <--- CORRECTED: This should be the SENDER'S image (your image URL)
              'type': 'text',
              'timeStamp': timestamp,
              'unseenCount': 0,
            });

        await onSuccess(newConversationRef.id);
      }
    } catch (e) {
      print('🔥 Error in createOrGetConversation: $e');
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db!.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String userID) {
    final ref = _db!
        .collection(_userCollection)
        .doc(userID)
        .collection(_converationsCollection);

    return ref.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => ConversationSnippet.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _db!
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');
    return _ref.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    return _db!
        .collection("Conversations") // Make sure this matches your Firestore
        .doc(conversationID)
        .snapshots()
        .map((snapshot) => Conversation.fromFirestore(snapshot));
  }
}
