import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos de l\'application'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Bienvenue sur Tutore App !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Cette application vous aide à organiser et suivre vos séances de tutorat. '
              'Vous pouvez :\n\n'
              '- Ajouter et gérer vos élèves\n'
              '- Planifier des séances de tutorat\n'
              '- Prendre des notes sur chaque séance\n'
              '- Recevoir des rappels pour vos rendez-vous\n\n'
              'Pour commencer, utilisez le menu principal pour accéder aux différentes fonctionnalités.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Besoin d\'aide ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Consultez la section d\'aide ou contactez le support via les paramètres.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}