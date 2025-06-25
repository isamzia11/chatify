import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  static DbService instance = DbService();
  FirebaseFirestore? _db;

  DbService() {
    _db = FirebaseFirestore.instance;
  }

  String _userCollection = 'Users';

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
}
