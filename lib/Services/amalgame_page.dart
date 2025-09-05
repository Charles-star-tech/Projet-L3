import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

class AmalgamePage extends StatefulWidget {
  final Tache tache;

  const AmalgamePage({super.key, required this.tache});

  @override
  State<AmalgamePage> createState() => _AmalgamePageState();
}

class _AmalgamePageState extends State<AmalgamePage> {
  @override
  void initState() {
    super.initState();

    // Affiche le dialog après que la page soit rendue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAmalgameDialog(context, widget.tache);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // Peut être vide ou décoratif
    );
  }

  void _showAmalgameDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementError(); // ❌ Compte comme une erreur partielle

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Presque ! 🤔"),
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TachesPage()),
              );
            },
            child: const Text("Continuer"),
          ),
        ],
      ),
    );
  }
}
