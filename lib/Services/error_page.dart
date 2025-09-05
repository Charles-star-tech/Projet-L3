import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

class ErrorPage extends StatefulWidget {
  final Tache tache;

  const ErrorPage({super.key, required this.tache});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    super.initState();

    // Affiche le dialog après que la page soit rendue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorDialog(context, widget.tache);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // Page vide ou personnalisable
    );
  }

  void _showErrorDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementError(); // ❌ Incrémente les erreurs

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Oups ❌"),
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TachesPage()),
              );
            },
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }
}
