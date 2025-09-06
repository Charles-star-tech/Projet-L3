import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';

class Tache {
  final int id;
  final List<String> motMoore;
  final String imageUrl;
  final List<String> sens;

  // 🔧 Constructeur
  Tache({
    required this.id,
    required this.motMoore,
    required this.imageUrl,
    required this.sens,
  });

  // Méthode pour créer un objet Tache à partir d’une map Firestore
  factory Tache.fromFirestore(Map<String, dynamic> data) {
    // id peut venir en int ou en String
    final rawId = data['id'];
    final id = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) ?? 0 : 0);

    // motMoore peut être String ou List
    final rawMotMoore = data['motMoore'];
    final motMoore = rawMotMoore is List
        ? rawMotMoore.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : (rawMotMoore is String && rawMotMoore.trim().isNotEmpty)
            ? [rawMotMoore]
            : <String>[];

    // sens peut être String ou List
    final rawSens = data['sens'];
    final sens = rawSens is List
        ? rawSens.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : (rawSens is String && rawSens.trim().isNotEmpty)
            ? [rawSens]
            : <String>[];

    return Tache(
      id: id,
      motMoore: motMoore,
      imageUrl: (data['imageUrl'] ?? '').toString(),
      sens: sens,
    );
  }
}
// end class Tache

class TachesPage extends StatelessWidget {
  const TachesPage({super.key});

  // Récupère les tâches depuis Firestore
  Future<List<Tache>> fetchTaches() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('taches').orderBy('id').get();

    return snapshot.docs
        .map((doc) => Tache.fromFirestore(doc.data()))
        .toList();
  }

  // Affiche le dialogue pour la tâche sélectionnée
  void _showTacheDialog(BuildContext context, Tache tache, List<Tache> allTaches) {
    final controller = TextEditingController();
    String? errorMessage;

    final parentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Quel est le nom de l'objet en mooré ?"),
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
                  return;
                }

                // ✅ Vérifie si c'est le mot du tache affiché
                bool success = tache.motMoore
                  .map((m) => m.toLowerCase())
                  .contains(saisie);

                Tache? tacheSaisie;
                  try {
                    tacheSaisie = allTaches.firstWhere(
                      (other) => other.id != tache.id &&
                                other.motMoore.map((m) => m.toLowerCase()).contains(saisie),
                    );
                  } catch (e) {
                    tacheSaisie = null; // pas trouvé
                  }

                bool existsAlternate = tacheSaisie != null;

                // ✅ Ferme bien le dialog
                Navigator.of(dialogContext, rootNavigator: true).pop();

                // ✅ Lancer la navigation APRÈS fermeture du dialog
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (success) {
                    ScoreTracker.success++;
                    _showSuccessDialog(context, tache);
                  } else if (existsAlternate) {
                    ScoreTracker.error++;
                    _showAmalgameDialog(parentContext, tache, saisie, tacheSaisie!);
                  } else {
                    ScoreTracker.error++;
                    _showErreurDialog(parentContext, tache);
                  }
                });
              },
              child: const Text('Valider'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  // Succès
  void _showSuccessDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementSuccess(); // compteur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bravo 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(tache.imageUrl, height: 120),
            const SizedBox(height: 10),
            Text(tache.motMoore.join(',')),
            ...tache.sens.map((s) => Text(s)).toList(),
            const SizedBox(height: 10),
            const Text(
              "Bonne transcription !",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Amalgame
  void _showAmalgameDialog(
    BuildContext context,
    Tache tacheSelectionnee,
    String saisie, // le mot saisi par l'utilisateur
    Tache tacheSaisie, // le Tache correspondant au mot saisi dans la collection
  ) {
    ScoreTracker.incrementAmalgame();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mot amalgamé ⚠️"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Image et détails du mot attendu
              const Text(
                "Réponse attendue :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Image.network(tacheSelectionnee.imageUrl, height: 120),
              const SizedBox(height: 5),
              Text(
                tacheSelectionnee.motMoore.join(', '),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              ...tacheSelectionnee.sens.map((s) => Text(s)).toList(),
              const Divider(height: 20, color: Colors.grey),
              // ✅ Image et détails du mot saisi
              const Text(
                "Mot saisi :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Image.network(tacheSaisie.imageUrl, height: 120),
              const SizedBox(height: 5),
              Text(
                saisie,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
              ...tacheSaisie.sens.map((s) => Text(s)).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Erreur
  void _showErreurDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementError(); // compteur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur ❌"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(tache.imageUrl, height: 120),
            const SizedBox(height: 10),
            const Text(
              "Ce n'était pas la bonne réponse.",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "La bonne réponse était :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              tache.motMoore.join(', '),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            ...tache.sens.map((s) => Text(s)).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Liste des tâches
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
                  onTap: () => _showTacheDialog(context, tache, taches),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
