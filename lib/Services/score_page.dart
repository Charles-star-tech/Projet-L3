import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class ScorePage extends StatelessWidget {
  final int transcriptionsCorrectes;
  final int transcriptionsIncorrectes;
  final int transcriptionsTotal;
  final int transcriptionsAmalgame;
  final int totalTaches;
  final int success;
  final int error;
  final int amalgame;

  const ScorePage({
    super.key,
    required this.transcriptionsCorrectes,
    required this.transcriptionsIncorrectes,
    required this.transcriptionsTotal,
    required this.transcriptionsAmalgame,
    required this.totalTaches,
    required this.success,
    required this.error,
    required this.amalgame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎯 Score")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              'Résultats',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // buildScoreCard("  Transcriptions totales", transcriptionsTotal, Colors.blue),
            buildScoreCard('✅ Transcriptions trouvées', transcriptionsCorrectes, Colors.green),
            buildScoreCard('Transcriptions Amalgame', transcriptionsAmalgame, Colors.orange),
            buildScoreCard('❌ Transcriptions non trouvées', transcriptionsIncorrectes, Colors.red),
            // buildScoreCard('Tâches totales', totalTaches, Colors.blue),
            buildScoreCard('✅ Tâches trouvées', success, Colors.green),
            buildScoreCard('❌ Tâches Amalgame', amalgame, Colors.orange),
            buildScoreCard('❌ Tâches non trouvées', error, Colors.red),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScoreCard(String title, int score, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.star, size: 32),
        title: Text(title),
        trailing: AnimatedFlipCounter(
          duration: const Duration(seconds: 2),
          value: score,
          textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
