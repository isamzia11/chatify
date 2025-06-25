import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackbarService {
  BuildContext? _buildContext;

  static SnackbarService instance = SnackbarService();

  SnackbarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
