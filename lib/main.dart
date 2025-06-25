import 'package:chatify/firebase_options.dart';
import 'package:chatify/pages/login_page.dart';
import 'package:chatify/pages/registration_page.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // or .safetyNet
    webProvider: ReCaptchaV3Provider('your-site-key'), // for web only
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
      navigatorKey: NavigationService.instance.navigatorKey,
      debugShowCheckedModeBanner: false, // optional: removes debug banner
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromRGBO(28, 27, 27, 1),
        colorScheme: ColorScheme.dark(
          primary: const Color.fromRGBO(42, 117, 188, 1),
          background: const Color.fromRGBO(28, 27, 27, 1),
        ),
        useMaterial3: true, // highly recommended for Flutter 3.x onwards
      ),
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
      },
      home: const LoginPage(),
    );
  }
}
