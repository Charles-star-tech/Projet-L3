import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

class AmalgamePage extends StatelessWidget {
  const AmalgamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    // Vérifie si l'argument est fourni et du bon type
    if (args == null || args is! Tache) {
      return Scaffold(
        appBar: AppBar(title: const Text("Amalgame")),
        body: const Center(
          child: Text("Aucune tâche fournie pour afficher l'amalgame."),
        ),
      );
    }

    final Tache tache = args;

    // Affiche le dialogue après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAmalgameDialog(context, tache);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Amalgame")),
      body: const Center(
        child: Text("Transcription amalgamée."),
      ),
    );
  }
}

void _showAmalgameDialog(BuildContext context, Tache tache) {
  ScoreTracker.incrementAmalgame(); // incrémente le score amalgame

  showDialog(
    context: context,
    barrierDismissible: false, // L'utilisateur doit cliquer sur OK
    builder: (context) => AlertDialog(
      title: const Text("Mot amalgamé ⚠️"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(tache.imageUrl, height: 120),
          const SizedBox(height: 10),
          const Text(
            "Bonne transcription, mais mauvais sens !",
            style: TextStyle(
              color: Colors.orange,
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
