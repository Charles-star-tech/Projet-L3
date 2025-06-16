import 'package:flutter/material.dart';
import 'package:tutore_vrais/Services/taches_page.dart';
import 'package:firebase_auth/firebase_auth.dart';


class JeuxDashboard extends StatelessWidget {
  const JeuxDashboard({super.key});

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DashboardButton(
              label: 'Transcrire',
              icon: Icons.edit,
              onPressed: () async {
                // Remplacez TaskTranscriptionPage par le widget réel si besoin
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TranscriptionFormPage(),
                  ),
                );
                // Traitez le résultat ici si besoin
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              label: 'Tâches',
              icon: Icons.task,
              onPressed: () async {
                // Remplacez TaskTranscriptionPage par le widget réel si besoin
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TachesPage(),
                  ),
                );
                // Traitez le résultat ici si besoin
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              label: 'Score',
              icon: Icons.score,
              onPressed: () {
                // Implémentez l'action Score ici
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const DashboardButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Ajoutez ce widget pour le formulaire de transcription
class TranscriptionFormPage extends StatefulWidget {
  const TranscriptionFormPage({Key? key}) : super(key: key);
  static int wordsTranscribed = 0;
  static int tasksCompleted = 0;
  @override
  State<TranscriptionFormPage> createState() => _TranscriptionFormPageState();
}

class _TranscriptionFormPageState extends State<TranscriptionFormPage> {
  String? selectedWord;
  final TextEditingController _transcriptionController =
      TextEditingController();

  // Remplacez cette liste par l'importation de mots.dart si besoin
  final List<String> words = ['mot1', 'mot2', 'mot3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transcrire un mot')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Choisissez un mot'),
              value: selectedWord,
              items: words
                  .map(
                    (word) => DropdownMenuItem(value: word, child: Text(word)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWord = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _transcriptionController,
              decoration: const InputDecoration(
                labelText: 'Transcription',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedWord == null || _transcriptionController.text.isEmpty
                  ? null
                  : () {
                      // Traitez la transcription ici
                      Navigator.pop(context);
                    },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
