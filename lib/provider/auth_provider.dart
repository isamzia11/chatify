import 'package:chatify/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late AuthStatus status;
  late FirebaseAuth _auth;
  String? _email;
  String? _password;
  String? _name;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    status = AuthStatus.NotAuthenticated;
    _checkCurrentUserisAuthenticated();
  }

  void setName(String? name) {
    _name = name;
    notifyListeners(); // Optional if UI depends on this value
  }

  void setEmail(String? email) {
    _email = email;
    notifyListeners(); // optional if you want UI to react
  }

  void setPassword(String? password) {
    _password = password;
    notifyListeners();
  }

  String? get email => _email;
  String? get password => _password;
  String? get name => _name;

  // void loginUserWithEmailAndPassword(String _email, String _password) async {
  //   status = AuthStaus.Authenticating;
  //   notifyListeners();
  //   try {
  //     UserCredential _result = await _auth.signInWithEmailAndPassword(
  //       email: _email,
  //       password: _password,
  //     );

  //     user = _result.user;
  //     status = AuthStaus.Authenticated;
  //     print('Loggedin Successfully');
  //     // Navigate to HomeScreen
  //   } catch (e) {
  //     status = AuthStaus.Error;
  //     print('Login Error');
  //     // Display an Error
  //   }
  //   notifyListeners();
  // }

  void _autoLogin() {
    if (user != null) {
      NavigationService.instance.navigateToReplacement('home');
    }
  }

  void _checkCurrentUserisAuthenticated() async {
    user = await _auth.currentUser!;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  Future<void> loginUserWithEmailAndPassword() async {
    if (_email == null || _password == null) {
      status = AuthStatus.Error;
      notifyListeners();
      print('Email or password is null');
      return;
    }

    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );

      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackbarService.instance.showSnackBarSuccess('Logged in Successfully');
      // Update lastSeen time
      // Navigate to HomePage
      NavigationService.instance.navigateToReplacement('home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        status = AuthStatus.UserNotFound;
        SnackbarService.instance.showSnackBarError(
          'No user found for that email.',
        );
      } else {
        status = AuthStatus.Error;
        SnackbarService.instance.showSnackBarError('Login error: ${e.message}');
      }
    } catch (e) {
      status = AuthStatus.Error;
      SnackbarService.instance.showSnackBarError('Unexpected error: $e');
    }

    notifyListeners();
  }

  void registerUserWithEmailAndPassword(
    String _email,
    String _password,
    Future<void> onSuccess(String _uid),
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user!.uid);
      SnackbarService.instance.showSnackBarSuccess(
        'User signed in successfully',
      );

      NavigationService.instance.goBack();
      // Navigate to Home page
      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      status = AuthStatus.Error;
      SnackbarService.instance.showSnackBarError('Error Registering User');
    }
    notifyListeners();
  }
}
