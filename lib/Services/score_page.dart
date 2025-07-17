import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:tutore_vrais/Services/score_tracker.dart';

class ScorePage extends StatelessWidget {
  final int transcriptionsCorrectes;
  final int transcriptionsIncorrectes;
  final int tachesCorrectes;
  final int tachesIncorrectes;

  const ScorePage({
    super.key,
    required this.transcriptionsCorrectes,
    required this.transcriptionsIncorrectes,
    required this.tachesCorrectes,
    required this.tachesIncorrectes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎯 Score")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Résultats',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            buildScoreCard('✅ Transcriptions trouvées', transcriptionsCorrectes, Colors.green),
            buildScoreCard('❌ Transcriptions non trouvées', transcriptionsIncorrectes, Colors.red),
            buildScoreCard('✅ Tâches trouvées', tachesCorrectes, Colors.green),
            buildScoreCard('❌ Tâches non trouvées', tachesIncorrectes, Colors.red),

            const SizedBox(height: 30),
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
