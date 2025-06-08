import 'package:flutter/material.dart';
import 'package:tutore_vrais/pages/login_page.dart';
import 'package:tutore_vrais/pages/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPage();
}

class _LoginOrRegisterPage extends State<LoginOrRegisterPage> {
  //initialisation
  bool showLoginPage = true;

  //taggle between login
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
          onTap: togglePages
      );
    }else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}