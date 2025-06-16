import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  Future<void> _updateUserRole(String userId, String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': newRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final email = user['email'] ?? 'Sans email';
              final role = user['role'] ?? 'user'; // Valeur par défaut

              // Liste des rôles possibles
              final List<String> roles = ['user', 'admin'];

              // Vérification de la validité de la valeur actuelle
              final currentRole = roles.contains(role) ? role : 'user';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(email),
                  subtitle: Text(
                    'Rôle actuel : ${currentRole == 'user' ? 'Utilisateur' : 'Admin'}',
                  ),
                  trailing: DropdownButton<String>(
                    value: currentRole,
                    items: roles.map((r) {
                      return DropdownMenuItem<String>(
                        value: r,
                        child: Text(r == 'user' ? 'Utilisateur' : 'Admin'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null && newValue != currentRole) {
                        _updateUserRole(userId, newValue);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
