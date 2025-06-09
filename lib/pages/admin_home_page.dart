import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Contrôleurs pour gérer les champs de texte
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  // Liste pour stocker les tâches et mots ajoutés
  List<Map<String, String>> _items = [];

  void _showAddMenu() {
    // Réinitialiser les contrôleurs
    _taskController.clear();
    _wordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
              // Indicateur de modal
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      onPressed: () => _addItem(),
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

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tâche et mot ajoutés avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                  backgroundColor: Colors.orange,
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
    // Libérer les contrôleurs
    _taskController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Administrateur'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Bienvenue, Administrateur!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aucune tâche ajoutée pour le moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddMenu,
              icon: Icon(Icons.add),
              label: Text('Ajouter une tâche'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                item['task']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Mot: ${item['word']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                onPressed: () => _deleteItem(index),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: Icon(Icons.add),
        tooltip: 'Ajouter une tâche',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}