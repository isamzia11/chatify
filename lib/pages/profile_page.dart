import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;

  const ProfilePage({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(child: _profilePageUI());
  }

  Widget _profilePageUI() {
    return Container(
      child: Center(
        child: SizedBox(
          height: height * 0.50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _userImageWidget(
                'https://cdn-icons-png.flaticon.com/512/10771/10771017.png',
              ),
              _userNameWidget('Sanji'),
              _userEmailWidget('sanji1@gmail.com'),
              _logoutButton(),
            ],
          ),
        ),
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
        onPressed: () {},
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
