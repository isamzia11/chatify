import 'package:chatify/firebase_options.dart';
import 'package:chatify/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
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
      home: const LoginPage(),
    );
  }
}
