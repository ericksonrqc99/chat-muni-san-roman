import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muni_san_roman/helpers/routes.dart';
import 'package:muni_san_roman/views/login_screen.dart';
import 'package:muni_san_roman/views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 240, 250, 255),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: "Fredoka",
          inputDecorationTheme: const InputDecorationTheme(isDense: true)),
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? LoginScreen.routeName
          : MainScreen.routeName,
    );
  }
}
