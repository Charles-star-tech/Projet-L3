import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text(
    'Bienvenue sur TAAY !',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
),
body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: ListView(
    children: const [
      SizedBox(height: 16),
      Text(
        'Cette application vous aide à transcrire des mots polysémiques en mooré. '
        'Vous pouvez :\n\n'
        '- Jouer à la transcription en cliquant sur "Transcrire"\n'
        '- Identifier des objets en mooré en cliquant sur "Tâche"\n'
        '- Consulter vos résultats en cliquant sur "Score"\n'
        '- Recevoir des rappels pour vos rendez-vous\n\n'
        'Pour commencer, vous devez avoir un clavier Gboard installé sur votre appareil.',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 24),
      Text(
        'Besoin d\'aide ?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text(
        'Contactez-nous par mail à : dabirecharles47@gmail.com',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 24),
      Text(
        'À propos de l\'application',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  ),
),
    );
  }
}