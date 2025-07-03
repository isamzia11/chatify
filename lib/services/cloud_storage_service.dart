import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage? _storage;
  Reference? _baseRef;

  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage!.ref();
  }

  // Future<TaskSnapshot> uploadUserImage(String _uid, File _image) {
  //   try {
  //    return  _baseRef.child(_profileImages).child(_uid).putFile(_image).onComplete;
  //   } catch (e) {}
  // }
  Future<TaskSnapshot> uploadUserImage(String _uid, File _image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(_profileImages)
          .child(_uid);
      UploadTask uploadTask = ref.putFile(_image);
      TaskSnapshot snapshot = await uploadTask;
      return snapshot;
    } catch (e) {
      rethrow; // Re-throws the caught error
    }
  }

  Future<TaskSnapshot> uploadMediaMessage(String _uid, File _file) async {
    var _timeStamp = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += "${_timeStamp.toString()}";
    try {
      return await _baseRef!
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file);
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
