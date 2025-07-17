import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';

class Tache {
  final int id;
  final String motMoore;
  final String imageUrl;
  final List<String> sens;

  Tache({
    required this.id,
    required this.motMoore,
    required this.imageUrl,
    required this.sens,
  });

  // 🔧 Méthode pour créer un objet Tache à partir d’un document Firestore
  factory Tache.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tache(
      id: data['id'] ?? 0,
      //id: doc.id, // 🔁 Utilise l'ID auto-généré du document comme identifiant
      motMoore: data['motMoore'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sens: [if (data['sens'] != null) data['sens']],
    );
  }
}

class TachesPage extends StatelessWidget {
  const TachesPage({super.key});

  // 🔄 Récupère les tâches depuis Firestore
  Future<List<Tache>> fetchTaches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('taches')
        .orderBy('id') // Assurez-vous que 'id' est un champ dans vos documents
        .get();
    return snapshot.docs.map((doc) => Tache.fromFirestore(doc)).toList();
  }

  // 🖼️ Affiche le dialogue avec l’image et champ texte
  void _showTacheDialog(BuildContext context, Tache tache) {
    final controller = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Quel est le nom de l\'objet en mooré ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(tache.imageUrl, height: 150),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Nom en mooré',
                  errorText: errorMessage,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final saisie = controller.text.trim().toLowerCase();
                if (saisie.isEmpty) {
                  setState(() => errorMessage = 'Veuillez entrer un mot.');
                } else {
                  Navigator.pop(context);
                  if (saisie == tache.motMoore.toLowerCase()) {
                    // ✅ Bonne réponse → popup animé
                    ScoreTracker.tachesCorrectes++;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // 🎖️ Trophée flottant
                            Positioned(
                              top: 10,
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 2),
                                tween: Tween(begin: 0.0, end: 10.0),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, value),
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/gain.png', //pubspec.yaml
                                  height: 100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 50,
                                left: 15,
                                right: 10,
                                bottom: 20,
                              ),
                              child: AlertDialog(
                                title: const Text('🎉 Félicitations !'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 6),

                                    //Image.network(tache.imageUrl, height: 140),
                                    CachedNetworkImage(
                                      imageUrl: tache.imageUrl,
                                      height: 150,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),

                                    const SizedBox(height: 10),
                                    Text(
                                      'Mot en mooré : ${tache.motMoore}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '🔸 Sens : ${tache.sens.isNotEmpty ? tache.sens[0] : 'Aucun'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop();
                                    },
                                    child: const Text('Fermer'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // ❌ Mauvaise réponse
                    ScoreTracker.tachesIncorrectes++;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('❌ Mauvaise réponse'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(tache.imageUrl, height: 150),
                            const SizedBox(height: 10),
                            Text('Mot en mooré : ${tache.motMoore}'),
                            ...tache.sens.map((s) => Text('🔸 Sens : $s')),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Ferme le dialogue
                            },
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text('Valider'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  // 🔁 Affiche la liste des tâches depuis Firestore
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des tâches')),
      body: FutureBuilder<List<Tache>>(
        future: fetchTaches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune tâche trouvée."));
          }

          final taches = snapshot.data!;
          return ListView.builder(
            itemCount: taches.length,
            itemBuilder: (context, index) {
              final tache = taches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Tâche ${tache.id}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showTacheDialog(context, tache),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
