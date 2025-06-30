import 'package:chatify/models/contact.dart';
import 'package:chatify/provider/auth_provider.dart';
import 'package:chatify/services/db_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;

  AuthProvider? _auth;

  ProfilePage({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,

        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Container(
      child: Builder(
        builder: (BuildContext _context) {
          _auth = Provider.of<AuthProvider>(_context);
          return StreamBuilder<Contact>(
            stream: DbService.instance.getUserData(_auth!.user!.uid),
            builder: (_context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                    shape: BoxShape.circle,
                  ),
                );
              }

              var _userData = snapshot.data!;

              return Center(
                child: SizedBox(
                  height: height * 0.50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _userImageWidget(
                        _userData.image ??
                            'https://cdn-icons-png.flaticon.com/512/10771/10771017.png',
                      ),
                      _userNameWidget(_userData.name ?? 'Unkown'),
                      _userEmailWidget(_userData.email ?? 'unknown@gmail.com'),
                      _logoutButton(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = height * 0.20;

    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(_image)),
      ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Container(
      height: height * 0.05,
      width: width,
      child: Text(
        _userName,
        style: TextStyle(color: Colors.white, fontSize: 30),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _userEmailWidget(String _email) {
    return Container(
      height: height * 0.03,
      width: width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return Container(
      height: height * 0.06,
      width: width * 0.80,
      child: MaterialButton(
        color: Colors.red,
        onPressed: () {
          _auth?.logoutUser(() async {
            return;
          });
        },
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
