import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutore_vrais/Services/mots_page.dart';
import 'package:tutore_vrais/Services/score_page.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';
import 'package:tutore_vrais/Services/taches_page.dart';

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
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MotsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              label: 'Tâches',
              icon: Icons.task,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TachesPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              label: 'Score',
              icon: Icons.score,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScorePage(
                      transcriptionsCorrectes:
                          ScoreTracker.transcriptionsCorrectes,
                      transcriptionsIncorrectes:
                          ScoreTracker.transcriptionsIncorrectes,
                      tachesCorrectes: ScoreTracker.tachesCorrectes,
                      tachesIncorrectes: ScoreTracker.tachesIncorrectes,
                    ),
                  ),
                );
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

// class TranscriptionFormPage extends StatefulWidget {
//   const TranscriptionFormPage({Key? key}) : super(key: key);

//   @override
//   State<TranscriptionFormPage> createState() => _TranscriptionFormPageState();
// }

// class _TranscriptionFormPageState extends State<TranscriptionFormPage> {
//   String? selectedWord;
//   final TextEditingController _transcriptionController =
//       TextEditingController();
//   List<Map<String, dynamic>> wordEntries = [];
//   bool isLoading = true;
//   String? resultMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchWordsFromFirestore();
//   }

//   // ✅ MÉTHODE POUR RÉCUPÉRER LES MOTS DE FIRESTORE
//   Future<void> fetchWordsFromFirestore() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('mots')
//           .get();

//       final loadedWords = snapshot.docs.map((doc) {
//         final data = doc.data();
//         // 🔎 AFFICHER EN CONSOLE LES MOTS POUR DÉBOGAGE
//         print("✅ Document Firestore : $data");

//         return {
//           'non phonétique': data['transcription_non_phonetique'],
//           'phonétique': data['trascriptions_phonétiques'],
//           'sens lexical': data['sens_lexicaux'],
//         };
//       }).toList();

//       setState(() {
//         wordEntries = loadedWords;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Erreur Firestore: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // ✅ VALIDATION DE LA TRANSCRIPTION PAR L’UTILISATEUR
//   void validerTranscription() {
//     final userInput = _transcriptionController.text.trim().toLowerCase();
//     final wordData = wordEntries.firstWhere(
//       (word) => word['transcription_non_phonetique'] == selectedWord,
//       orElse: () => {},
//     );

//     if (wordData.isNotEmpty &&
//         userInput ==
//             wordData['trascriptions_phonétiques'].toString().toLowerCase()) {
//       setState(() {
//         resultMessage =
//             "✅ Bravo !\n"
//             "📝 Non phonétique : ${wordData['transcription_non_phonetique']}\n"
//             "🔤 Phonétique : ${wordData['transcriptions_phonetiques']}\n"
//             "📖 Sens lexical : ${wordData['sens_lexicaux']}";
//       });
//     } else {
//       setState(() {
//         resultMessage = "❌ Désolé, transcription incorrecte.";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Transcrire un mot')),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : wordEntries.isEmpty
//             // 🔔 MESSAGE SI AUCUN MOT DISPONIBLE
//             ? const Center(child: Text("Aucun mot trouvé dans Firestore."))
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // ✅ MENU DÉROULANT POUR CHOISIR UN MOT
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: 'Choisissez un mot',
//                     ),
//                     value: selectedWord,
//                     items: wordEntries.map((word) {
//                       final String label = word['trascription_non_phonétique']
//                           .toString();
//                       return DropdownMenuItem<String>(
//                         value: label,
//                         child: Text(label),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedWord = value;
//                         resultMessage = null;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _transcriptionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Entrez la transcription phonétique',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed:
//                         selectedWord == null ||
//                             _transcriptionController.text.isEmpty
//                         ? null
//                         : validerTranscription,
//                     child: const Text('Valider'),
//                   ),
//                   const SizedBox(height: 20),
//                   if (resultMessage != null)
//                     Text(
//                       resultMessage!,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: resultMessage!.startsWith("✅")
//                             ? Colors.green
//                             : Colors.red,
//                       ),
//                     ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
