import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    // Vérifie si l'argument est fourni et du bon type
    if (args == null || args is! Tache) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: const Center(
          child: Text("Aucune tâche fournie pour afficher l'erreur."),
        ),
      );
    }

    final Tache tache = args;

    // Affiche le dialogue après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErreurDialog(context, tache);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Erreur")),
      body: const Center(
        child: Text("Transcription inconnue."),
      ),
    );
  }
}

void _showErreurDialog(BuildContext context, Tache tache) {
  ScoreTracker.incrementError(); // incrémente le compteur d'erreurs

  showDialog(
    context: context,
    barrierDismissible: false, // L'utilisateur doit cliquer sur OK
    builder: (context) => AlertDialog(
      title: const Text("Erreur ❌"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(tache.imageUrl, height: 120),
          const SizedBox(height: 10),
          const Text(
            "Transcription inconnue.",
            style: TextStyle(
              color: Colors.red,
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
