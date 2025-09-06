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
  bool success = false;
  bool existsAlternate = false;
  bool error = false;

  //bool get existsAlternate => someList.isNotEmpty;

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
    //

    // Vérifie si la saisie correspond à la transcription phonétique attendue
    if (_selectedSensIndex != null &&
        mot.transcriptionsPhonetiques.isNotEmpty &&
        saisie ==
            mot.transcriptionsPhonetiques[_selectedSensIndex!].toLowerCase()) {
      success = true;
    }
    // Vérifie si l’utilisateur a saisi la transcriptionNonPhonetique du mot
    else if (saisie == mot.transcriptionNonPhonetique.toLowerCase()) {
      existsAlternate = true;
    }
    else {
      error = true;
    }

    // Mise à jour des scores
    if (success) {
      ScoreTracker.transcriptionsCorrectes++;
    } else if (existsAlternate) {
      ScoreTracker.transcriptionsAmalgame++;
    } else if (error) {
      ScoreTracker.error++;
    }

    // Sauvegarde + affichage
    _saveScores();
    _showResultDialog(
      context,
      mot,
      success,
      existsAlternate,
      error,
      _selectedSensIndex,
    );
  }

  void _showResultDialog(
    BuildContext context,
    Mot mot,
    bool success,
    bool existsAlternate,
    bool error,
    int? selectedIndex,
  ) {
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
              Column(
                children: [
                  Text(
                    success
                        ? '🎉 Félicitations !'
                        : existsAlternate
                        ? 'Mot Amalgamer'
                        : '❌ Mauvaise réponse',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              //const SizedBox(height: 12),
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
                  'Phonétiques : ${selectedIndex != null && selectedIndex < mot.transcriptionsPhonetiques.length ? mot.transcriptionsPhonetiques[selectedIndex].toLowerCase() : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sens lexicaux : ${selectedIndex != null && selectedIndex < mot.sensLexicaux.length ? mot.sensLexicaux[selectedIndex].toLowerCase() : ''}',
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
            // Sélection du mot (inchangé)
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

            // Sélection du sens avec index
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

            // Champ transcription phonétique
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

            // Bouton valider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // espace équilibré
              children: [
                ElevatedButton(
                  onPressed: _validerTranscription,
                  child: const Text('Valider'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour'),
                ),
              ],
            ),
            // Message de résultat
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
}
