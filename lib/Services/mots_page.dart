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
      transcriptionsPhonetiques:
          List<String>.from(data['transcriptions_phonetiques'] ?? []),
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
  String? _selectedWord;
  String? _resultMessage;
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

  void _validerTranscription() {
    if (_selectedWord == null) {
      setState(() => _resultMessage = 'Veuillez choisir un mot.');
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

    final success = mot.transcriptionsPhonetiques
        .map((t) => t.toLowerCase())
        .contains(saisie);

    if (success) ScoreTracker.transcriptionsCorrectes++;
    else ScoreTracker.transcriptionsIncorrectes++;

    _saveScores();
    _showResultDialog(context, mot, success);
    setState(() {
      _resultMessage = success ? "Bravo !" : "Erreur, essaie encore.";
    });
  }

  void _showResultDialog(BuildContext context, Mot mot, bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (success)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 10),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (_, offset, child) =>
                    Transform.translate(offset: Offset(0, offset), child: child),
                child:
                    Image.asset('assets/images/gain.png', height: 100),
              ),
            const SizedBox(height: 10),
            Text(
              success ? '🎉 Félicitations !' : '❌ Mauvaise réponse',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
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
                'Phonétiques : ${mot.transcriptionsPhonetiques.join(", ")}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sens lexicaux : ${mot.sensLexicaux.join(", ")}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jeu de transcription')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choisissez un mot (non‑phonétique)',
              border: OutlineInputBorder(),
            ),
            value: _selectedWord,
            items: _mots.map((m) => m.transcriptionNonPhonetique).toSet().map(
              (word) => DropdownMenuItem(
                value: word,
                child: Text(word),
              ),
            ).toList(),
            onChanged: (v) {
              setState(() {
                _selectedWord = v;
                _controller.clear();
                _resultMessage = null;
              });
            },
          ),
        ),
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
        ElevatedButton(onPressed: _validerTranscription, child: const Text('Valider')),
        if (_resultMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _resultMessage!,
              style: TextStyle(
                color: _resultMessage!.startsWith("Bravo") ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ]),
    );
  }
}
