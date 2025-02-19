import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/Pages/HomePage.dart';
import 'package:flutter_ebook/Pages/LoginPage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHomePage(title: "HomePage");
        } else {
          return LoginPage();
        }
      },
    );
  }
}
