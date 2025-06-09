import 'package:flutter/material.dart';
import 'package:tutore_vrais/pages/Settings_page.dart';
import 'package:tutore_vrais/pages/admin_home_page.dart';
import 'package:tutore_vrais/pages/ajout_mot_page.dart';
import 'package:tutore_vrais/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutore_vrais/pages/profile_page.dart';
import 'package:tutore_vrais/pages/users_list_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Empêche l'initialisation multiple
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      routes: {
        '/home': (context) => AdminHomePage(),
        '/ajoutmot': (context) => AjoutMotPage(),
        '/settingspage': (context) => SettingsPage(),
        //'/profile': (context) => ProfilePage(),
        '/users': (context) => UsersListPage(),
      },
    );
  }
}
