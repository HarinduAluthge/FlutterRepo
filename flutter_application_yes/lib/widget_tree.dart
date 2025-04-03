import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_yes/auth.dart';
import 'package:flutter_application_yes/main_navigation.dart';
import 'login_register_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
const WidgetTree({super.key});

@override
State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
@override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: Auth().authStateChange,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasData) {
        return const MainNavigation();
      } else {
        return const LoginPage();
      }
    },
  );
}
}

