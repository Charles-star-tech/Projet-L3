import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

class SuccesPage extends StatefulWidget {
  final Tache tache;

  const SuccesPage({super.key, required this.tache});

  @override
  State<SuccesPage> createState() => _SuccesPageState();
}

get tache => null;

class _SuccesPageState extends State<SuccesPage> {
  @override
  void initState() {
    super.initState();

    // Affiche le dialog après que la page soit rendue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuccessDialog(context, widget.tache);
    });
  }

  @override
  Widget build(BuildContext context) {
    // You can return an empty Scaffold or any widget as the page content
    return Scaffold(
      body: Container(),
    );
  }

  void _showSuccessDialog(BuildContext context, Tache tache) {
    ScoreTracker.incrementSuccess(); // ✅ incrémente le score

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TachesPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  
}
