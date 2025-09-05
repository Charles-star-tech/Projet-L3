import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';

class Tache {
  final int id;
  final String motMoore;
  final String imageUrl;
  final List<String> sens;

  // 🔧 Constructeur
  Tache({
    required this.id,
    required this.motMoore,
    required this.imageUrl,
    required this.sens,
  });

  // 🔧 Méthode pour créer un objet Tache à partir d’un document Firestore
  factory Tache.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // ✅ peut être null
    if (data == null) {
      throw Exception("Le document ${doc.id} est vide !");
    }

    return Tache(
      id: data['id'] ?? 0,
      motMoore: data['motMoore'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sens: data['sens'] != null
          ? [data['sens'] as String] // ✅ transforme ton String en List<String>
          : [],
    );
  }
  // ✅ Fournit les transcriptions alternatives
  List<String> get toutesTranscriptions => sens;
}

class TachesPage extends StatelessWidget {
  const TachesPage({super.key});

  BuildContext? get dialogContext => null;

  // Récupère les tâches depuis Firestore
  Future<List<Tache>> fetchTaches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('taches')
        .orderBy('id')
        .get();

    // ✅ Filtrer les documents vides avant de mapper
    return snapshot.docs
        .where((doc) => doc.data() != null)
        .map((doc) => Tache.fromFirestore(doc))
        .toList();
    //return snapshot.docs.map((doc) => Tache.fromFirestore(doc)).toList();
  }

  // Affiche le dialogue pour la tâche sélectionnée
  // ✅ Succès
  void _showTacheDialog(BuildContext context, Tache tache) {
    final controller = TextEditingController();
    String? errorMessage;

    // ✅ Garde une copie du context d'origine ici
    final parentContext = context; // 👈 AJOUTE cette ligne

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

                bool success = saisie == tache.motMoore.toLowerCase();
                bool existsAlternate = tache.toutesTranscriptions
                    .map((m) => m.toLowerCase())
                    .contains(saisie);

                // ✅ Ferme bien le dialog
                Navigator.of(dialogContext, rootNavigator: true).pop();

                // ✅ Lancer la navigation APRÈS fermeture du dialog
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // ✅ Utilise le context de la page principale
                  if (success) {
                    ScoreTracker.success++;
                    _showSuccessDialog(context, tache);
                  } else if (existsAlternate) {
                    ScoreTracker.error++;
                    _showAmalgameDialog(parentContext, tache);
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

  // ✅ Succès
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
            Text(tache.motMoore),
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

  // ⚠️ Amalgame
  void _showAmalgameDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementAmalgame(); // compteur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mot amalgamé ⚠️"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(tache.imageUrl, height: 120),
            const SizedBox(height: 10),
            Text(
              "Tu as entré une transcription valide,\nmais ce n'est pas celle attendue.",
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Réponse attendue :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              tache.motMoore,
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

  // ❌ Erreur
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
              tache.motMoore,
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

  // Affiche le dialogue avec l'image et le champ texte + bouton Valider

  // 🔁 Liste des tâches
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
