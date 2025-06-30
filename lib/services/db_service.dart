import 'package:chatify/models/contact.dart';
import 'package:chatify/models/conversation_snippet.dart';
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

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db!.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var _ref = _db!
        .collection(_userCollection)
        .doc(_userID)
        .collection(_converationsCollection);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
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
}
