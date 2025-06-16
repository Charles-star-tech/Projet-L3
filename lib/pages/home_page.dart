import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../Services/jeux.dart'; // Assure-toi que ce chemin est correct

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  // Puis redirige vers la page login et remplace la navigation pour ne pas revenir en arrière
  Navigator.pushReplacementNamed(context, '/login');
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue, ${user?.email ?? 'Utilisateur'}"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 115, 160, 238),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Color.alphaBlend(
          Colors.lightBlue,
          Colors.purpleAccent,
        ),
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.account_box_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text("Accueil", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box_outlined, color: Colors.white),
              title: Text("Profil", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text(
                "Partager l'application",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Share.share(
                  'Télécharge mon application ici : https://drive.google.com/file/d/1XyzABC123456/view?usp=sharing',
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text("Info", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/info');
              },
            ),
            const Spacer(),

            // ✅ Bouton de déconnexion en bas à droite
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: IconButton(
                  onPressed: () => signUserOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Déconnexion',
                ),
              ),
            ),
          ],
        ),
      ),

      body: const JeuxDashboard(),
    );
  }
}
