import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage? _storage;
  Reference? _baseRef;

  String _profileImages = "profile_images";

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
}
