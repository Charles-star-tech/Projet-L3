import 'package:flutter/material.dart';

class Tache {
  final String id;
  final String nom;
  final String imageUrl;

  Tache({required this.id, required this.nom, required this.imageUrl});
}

// Exemple de base de données simulée
final List<Tache> tachesDB = [
  Tache(id: '1', nom: 'Nettoyer', imageUrl: 'https://via.placeholder.com/150'),
  Tache(id: '2', nom: 'Cuisiner', imageUrl: 'https://via.placeholder.com/150'),
];

class TachesPage extends StatelessWidget {
  const TachesPage({Key? key}) : super(key: key);

  void _showTacheDialog(BuildContext context, Tache tache) {
    final TextEditingController controller = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Quel est le nom de l\'objet ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  tache.imageUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'objet',
                  errorText: errorMessage,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String saisie = controller.text.trim();

                if (saisie.isEmpty) {
                  setState(() {
                    errorMessage = 'Veuillez entrer un nom.';
                  });
                } else if (saisie.toLowerCase() == tache.nom.toLowerCase()) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Bravo, bonne réponse !')),
                  );
                } else {
                  setState(() {
                    errorMessage = '❌ Mauvaise réponse.';
                  });
                }
              },
              child: const Text('Valider'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des tâches')),
      body: ListView.builder(
        itemCount: tachesDB.length,
        itemBuilder: (context, index) {
          final tache = tachesDB[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Tâche #${tache.id}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showTacheDialog(context, tache),
            ),
          );
        },
      ),
    );
  }
}
