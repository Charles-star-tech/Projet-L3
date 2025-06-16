import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AjoutMotPage extends StatefulWidget {
  @override
  _AjoutMotPageState createState() => _AjoutMotPageState();
}

class _AjoutMotPageState extends State<AjoutMotPage> {
  final _formKey = GlobalKey<FormState>();
  final _nonPhoneticController = TextEditingController();
  List<TextEditingController> _phoneticControllers = [TextEditingController()];
  List<TextEditingController> _senseControllers = [TextEditingController()];

  void _addPhoneticField() {
    setState(() => _phoneticControllers.add(TextEditingController()));
  }

  void _addSenseField() {
    setState(() => _senseControllers.add(TextEditingController()));
  }

  bool _isLoading = false;

  Future<void> _saveToFirestore() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final transcriptionNonPhon = _nonPhoneticController.text.trim();
        final transcriptionsPhon = _phoneticControllers
            .map((controller) => controller.text.trim())
            .where((val) => val.isNotEmpty)
            .toList();
        final senses = _senseControllers
            .map((controller) => controller.text.trim())
            .where((val) => val.isNotEmpty)
            .toList();

        await FirebaseFirestore.instance.collection('mots').add({
          'transcription_non_phonetique': transcriptionNonPhon,
          'transcriptions_phonetiques': transcriptionsPhon,
          'sens_lexicaux': senses,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mot enregistré avec succès')));

        // Réinitialiser les champs
        _nonPhoneticController.clear();
        setState(() {
          _phoneticControllers = [TextEditingController()];
          _senseControllers = [TextEditingController()];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nonPhoneticController.dispose();
    _phoneticControllers.forEach((c) => c.dispose());
    _senseControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  Widget _buildDynamicFields(
    List<TextEditingController> controllers,
    String label,
    VoidCallback onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ...controllers.map((controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextFormField(
              controller: controller,
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: label,
              ),
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add),
            label: Text('Ajouter'),
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur d\'initialisation Firebase')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Ajouter un mot'),
            backgroundColor: Colors.deepOrange,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Transcription non phonétique',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  TextFormField(
                    controller: _nonPhoneticController,
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ex: ãbga',
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDynamicFields(
                    _phoneticControllers,
                    'Transcription phonétique',
                    _addPhoneticField,
                  ),
                  SizedBox(height: 16),
                  _buildDynamicFields(
                    _senseControllers,
                    'Sens lexical',
                    _addSenseField,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          icon: Icon(Icons.save),
                          label: Text('Enregistrer'),
                          onPressed: _saveToFirestore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
