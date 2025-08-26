import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';

import '../Services/jeux.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  final List<Map<String, String>> _items = [];

  // ignore: unused_element
  void _showAddMenu() {
    _taskController.clear();
    _wordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      // ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Ajouter une tâche et un mot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Tâche',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.task),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: 'Mot',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      child: Text('Ajouter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItem() {
    if (_taskController.text.isNotEmpty && _wordController.text.isNotEmpty) {
      setState(() {
        _items.add({
          'task': _taskController.text,
          'word': _wordController.text,
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tâche et mot ajoutés avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Color.fromARGB(255, 115, 160, 238),
        ),
      );
    }
  }

  // ignore: unused_element
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cet élément ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Élément supprimé'),
                  backgroundColor: Color.fromRGBO(25, 52, 30, 200),
                ),
              );
            },
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Administrateur'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color.alphaBlend(Colors.lightBlue, Colors.purpleAccent),
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(Icons.account_box_outlined, size: 48, color: Colors.white),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text("Accueil", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.library_add, color: Colors.white),
              title: Text("Ajouter un mot", 
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pushNamed(context, '/ajoutmot'),
            ),

            ListTile(
              leading: Icon(Icons.people, color: Colors.white),
              title: Text(
                "Utilisateurs",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/users');
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
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text("Paramètre", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),

            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text("Partager l'application", style: TextStyle(color: Colors.white)),
              onTap: () {
                Share.share('Télécharge mon application ici : https://drive.google.com/file/d/1XyzABC123456/view?usp=sharing');
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
                  onPressed: signUserOut,
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
