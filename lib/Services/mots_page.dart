import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MotsPage extends StatefulWidget {
  const MotsPage({Key? key}) : super(key: key);

  @override
  State<MotsPage> createState() => _MotsPageState();
}

class _MotsPageState extends State<MotsPage> {
  final TextEditingController _controller = TextEditingController();
  String? _resultMessage;

  Stream<QuerySnapshot> getMotsStream() {
    return FirebaseFirestore.instance.collection('mots').snapshots();
  }

  Future<void> _validerTranscription() async {
    final userInput = _controller.text.trim().toLowerCase();
    if (userInput.isEmpty) {
      setState(() {
        _resultMessage = "Veuillez entrer un mot.";
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('mots')
        .where('mot', isEqualTo: userInput)
        .get();

    setState(() {
      if (snapshot.docs.isNotEmpty) {
        _resultMessage = "Bravo ! Le mot est correct.";
      } else {
        _resultMessage = "Désolé, ce mot n'existe pas dans la base de données.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des mots')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Transcrivez un mot',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _validerTranscription,
            child: const Text('Valider'),
          ),
          if (_resultMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _resultMessage!,
                style: TextStyle(
                  color: _resultMessage!.startsWith("Bravo") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMotsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erreur de chargement'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Aucun mot trouvé.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final mot = data['mot'] ?? 'Mot inconnu';
                    return ListTile(
                      title: Text(mot),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}