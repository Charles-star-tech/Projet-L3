import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';

class Mot {
  final String transcriptionNonPhonetique;
  final List<String> transcriptionsPhonetiques;
  final List<String> sensLexicaux;

  Mot({
    required this.transcriptionNonPhonetique,
    required this.transcriptionsPhonetiques,
    required this.sensLexicaux,
  });

  factory Mot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mot(
      transcriptionNonPhonetique: data['transcription_non_phonetique'] ?? '',
      transcriptionsPhonetiques: List<String>.from(
        data['transcriptions_phonetiques'] ?? [],
      ),
      sensLexicaux: List<String>.from(data['sens_lexicaux'] ?? []),
    );
  }
}

class MotsPage extends StatefulWidget {
  const MotsPage({Key? key}) : super(key: key);

  @override
  State<MotsPage> createState() => _MotsPageState();
}

class _MotsPageState extends State<MotsPage> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedSens;
  String? _selectedWord;
  String? _resultMessage;
  int? _selectedSensIndex;
  List<Mot> _mots = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    fetchMots();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    ScoreTracker.transcriptionsCorrectes = _prefs.getInt('tc') ?? 0;
    ScoreTracker.transcriptionsIncorrectes = _prefs.getInt('ti') ?? 0;
  }

  Future<void> _saveScores() async {
    await _prefs.setInt('tc', ScoreTracker.transcriptionsCorrectes);
    await _prefs.setInt('ti', ScoreTracker.transcriptionsIncorrectes);
  }

  Future<void> fetchMots() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mots')
          .orderBy('timestamp', descending: false)
          .get();
      setState(() {
        _mots = snapshot.docs.map((d) => Mot.fromFirestore(d)).toList();
      });
    } catch (e) {
      debugPrint("Erreur fetchMots: $e");
    }
  }

//Method to validate transcription
  void _validerTranscription() {
    if (_selectedWord == null || _selectedSensIndex == null) {
      setState(() => _resultMessage = 'Veuillez choisir un mot et un sens.');
      return;
    }

    final saisie = _controller.text.trim().toLowerCase();
    final mot = _mots.firstWhere(
      (m) => m.transcriptionNonPhonetique == _selectedWord,
      orElse: () => Mot(
        transcriptionNonPhonetique: '',
        transcriptionsPhonetiques: [],
        sensLexicaux: [],
      ),
    );

    bool success = false;
    bool existsAlternate = false;

    // Vérifie si la saisie correspond à la transcription du sens choisi
    // et détecte si c’est une transcription correcte pour un autre sens.
    for (int i = 0; i < mot.transcriptionsPhonetiques.length; i++) {
      final t = mot.transcriptionsPhonetiques[i].toLowerCase();
      if (t == saisie) {
        if (i == _selectedSensIndex) {
          success = true;
        } else {
          if (mot.sensLexicaux[i] == mot.sensLexicaux[_selectedSensIndex!]) {
            success = true;
          } else {
            existsAlternate = true;
          }
          //existsAlternate = true;
        }
        break;
      }
    }
    if (success) {
    // ✅ Bonne transcription + bon sens
    ScoreTracker.transcriptionsCorrectes++;
    ScoreTracker.transcriptionsTotal++;
    ScoreTracker.success++;   // pour les tâches
  } else if (existsAlternate) {
    // 🟧 Transcription correcte mais mauvais sens
    ScoreTracker.transcriptionsAmalgame++;
    ScoreTracker.transcriptionsTotal++;
    ScoreTracker.amalgame++;  // pour les tâches
  } else {
    // ❌ Mauvaise transcription
    ScoreTracker.transcriptionsIncorrectes++;
    ScoreTracker.transcriptionsTotal++;
    ScoreTracker.error++;     // pour les tâches
  }
    _saveScores();
    _showResultDialog(context, mot, success, _selectedSensIndex);
    setState(() {
      _resultMessage = success ? "Bravo !" : "Erreur, essaie encore.";
    });
  }

  void _showResultDialog(BuildContext context, Mot mot, bool success, int? selectedIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (success)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 10),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (_, offset, child) => Transform.translate(
                    offset: Offset(0, offset),
                    child: child,
                  ),
                  child: Image.asset('assets/images/gain.png', height: 100),
                ),
              const SizedBox(height: 10),
              Text(
                success ? '🎉 Félicitations !' : '❌ Mauvaise réponse',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Non‑phonétique : ${mot.transcriptionNonPhonetique}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phonétiques : ${selectedIndex != null && selectedIndex < mot.transcriptionsPhonetiques.length
                      ? mot.transcriptionsPhonetiques[selectedIndex].toLowerCase()
                      : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sens lexicaux : ${selectedIndex != null && selectedIndex < mot.sensLexicaux.length
                      ? mot.sensLexicaux[selectedIndex].toLowerCase()
                      : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jeu de transcription')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1⃣ Sélection du mot (inchangé)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Choisissez un mot (non-phonétique)',
                  border: OutlineInputBorder(),
                ),
                value: _selectedWord,
                items: _mots
                    .map((m) => m.transcriptionNonPhonetique)
                    .toSet()
                    .map(
                      (word) =>
                          DropdownMenuItem(value: word, child: Text(word)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedWord = v;
                    _selectedSensIndex = null; // réinitialisation
                    _controller.clear();
                    _resultMessage = null;
                  });
                },
              ),
            ),

            // 2⃣ Sélection du sens avec index
            if (_selectedWord != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Choisissez un sens',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSensIndex,
                  items: _mots
                      .firstWhere(
                        (m) => m.transcriptionNonPhonetique == _selectedWord,
                        orElse: () => Mot(
                          transcriptionNonPhonetique: '',
                          transcriptionsPhonetiques: [],
                          sensLexicaux: [],
                        ),
                      )
                      .sensLexicaux
                      .asMap()
                      .entries
                      .map((entry) {
                        int idx = entry.key;
                        String sens = entry.value;
                        return DropdownMenuItem<int>(
                          value: idx,
                          child: Text(sens),
                        );
                      })
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSensIndex = val;
                      _resultMessage = null;
                    });
                  },
                ),
              ),

            // 3⃣ Champ transcription phonétique
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Transcription phonétique',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // 4⃣ Bouton valider
            ElevatedButton(
              onPressed: _validerTranscription,
              child: const Text('Valider'),
            ),

            // 5⃣ Message de résultat
            if (_resultMessage != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _resultMessage!,
                  style: TextStyle(
                    color: _resultMessage!.startsWith("Bravo")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: const Text('Jeu de transcription')),
  //       body: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: DropdownButtonFormField<String>(
  //                 decoration: const InputDecoration(
  //                   labelText: 'Choisissez un mot (non‑phonétique)',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 value: _selectedWord,
  //                 items: _mots.map((m) => m.transcriptionNonPhonetique).toSet().map(
  //                   (word) => DropdownMenuItem(
  //                     value: word,
  //                     child: Text(word),
  //                   ),
  //                 ).toList(),
  //                 onChanged: (v) {
  //                   setState(() {
  //                     _selectedWord = v;
  //                     _selectedSens = null;
  //                     _controller.clear();
  //                     _resultMessage = null;
  //                   });
  //                 },
  //               ),
  //             ),
  //             if (_selectedWord != null && _selectedWord!.isNotEmpty)
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                 child: DropdownButtonFormField<String>(
  //                   decoration: const InputDecoration(
  //                     labelText: 'Choisissez un sens',
  //                     border: OutlineInputBorder(),
  //                   ),
  //                   value: _selectedSens,
  //                   items: _mots
  //                       .firstWhere((m) => m.transcriptionNonPhonetique == _selectedWord,
  //                         orElse: () => Mot(transcriptionNonPhonetique: '', transcriptionsPhonetiques: [], sensLexicaux: []),
  //                       )
  //                       .sensLexicaux
  //                       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
  //                       .toList(),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       _selectedSens = value;
  //                       _resultMessage = null;
  //                     });
  //                   },
  //                   validator: (value) => value == null ? 'Veuillez choisir un sens' : null,
  //                 ),
  //               ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               child: TextField(
  //                 controller: _controller,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Transcription phonétique',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton(onPressed: _validerTranscription, child: const Text('Valider')),
  //             if (_resultMessage != null)
  //               Padding(
  //                 padding: const EdgeInsets.all(8),
  //                 child: Text(
  //                   _resultMessage!,
  //                   style: TextStyle(
  //                     color: _resultMessage!.startsWith("Bravo") ? Colors.green : Colors.red,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
}
