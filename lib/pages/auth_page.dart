import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutore_vrais/pages/login_page.dart';

import 'home_page.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //L'utilisateur est connecté
          if (snapshot.hasData) {
            return HomePage();
          }

          //l'utilisateur n'est pas connecté
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}