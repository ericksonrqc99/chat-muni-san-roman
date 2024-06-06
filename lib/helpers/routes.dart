import 'package:flutter/material.dart';
import 'package:muni_san_roman/views/login_screen.dart';
import 'package:muni_san_roman/views/register_screen.dart';
import 'package:muni_san_roman/views/chat_screen.dart';
import 'package:muni_san_roman/views/main_screen.dart';

final Map<String, WidgetBuilder> routes = {
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  MainScreen.routeName: (context) => const MainScreen(),
};
