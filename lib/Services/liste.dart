//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Liste d'historique simulée
final List<String> historique = [
  'Tâche 1 complétée',
  'Tâche 2 supprimée',
  'Tâche 3 ajoutée',
  'Tâche 4 modifiée',
];

// Widget pour afficher l'historique
class HistoriquePage extends StatelessWidget {
  const HistoriquePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: historique.isEmpty
          ? const Center(child: Text('Aucun historique pour le moment.'))
          : ListView.builder(
              itemCount: historique.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(historique[index]),
                );
              },
            ),
    );
  }
}

// body: _items.isEmpty
// ? Center(
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Icon(
// Icons.admin_panel_settings,
// size: 80,
// color: Colors.grey[400],
// ),
// SizedBox(height: 16),
// Text(
// 'Bienvenue, Administrateur!',
// style: TextStyle(
// fontSize: 24,
// fontWeight: FontWeight.bold,
// color: Colors.grey[600],
// ),
// ),
// SizedBox(height: 8),
// Text(
// 'Aucune tâche ajoutée pour le moment',
// style: TextStyle(fontSize: 16, color: Colors.grey[500]),
// ),
// SizedBox(height: 20),
// ElevatedButton.icon(
// onPressed: _showAddMenu,
// icon: Icon(Icons.add),
// label: Text('Ajouter une tâche'),
// ),
// ],
// ),
// )
//     : ListView.builder(
// padding: EdgeInsets.all(16),
// itemCount: _items.length,
// itemBuilder: (context, index) {
// final item = _items[index];
// return Card(
// margin: EdgeInsets.only(bottom: 12),
// elevation: 2,
// child: ListTile(
// leading: CircleAvatar(
// backgroundColor: Colors.blue,
// child: Text(
// '${index + 1}',
// style: TextStyle(color: Colors.white),
// ),
// ),
// title: Text(
// item['task']!,
// style: TextStyle(fontWeight: FontWeight.bold),
// ),
// subtitle: Text(
// 'Mot: ${item['word']}',
// style: TextStyle(color: Colors.grey[600]),
// ),
// trailing: IconButton(
// onPressed: () => _deleteItem(index),
// icon: Icon(Icons.delete, color: Colors.red),
// ),
// ),
// );
// },
// ),
// //
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class Tache {
//   final String id;
//   final String nomMoore;
//   final String imagePath;

//   Tache({required this.id, required this.nomMoore, required this.imagePath});

//   Future<String> getImageUrl() async {
//     return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
//   }

//   factory Tache.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Tache(
//       id: data['id'],
//       nomMoore: data['nom_moore'],
//       imagePath: data['image'],
//     );
//   }
// }

// Future<List<Tache>> fetchTaches() async {
//   final snapshot = await FirebaseFirestore.instance.collection('taches').get();
//   return snapshot.docs.map((doc) => Tache.fromFirestore(doc)).toList();
// }

// FutureBuilder<List<Tache>>(
//   future: fetchTaches(),
//   builder: (context, snapshot) {
//     if (!snapshot.hasData) return const CircularProgressIndicator();
//     final taches = snapshot.data!;
//     return ListView.builder(
//       itemCount: taches.length,
//       itemBuilder: (context, index) {
//         final tache = taches[index];
//         return ListTile(
//           title: Text('Tâche #${tache.id}'),
//           onTap: () => _showTacheDialog(context, tache),
//         );
//       },
//     );
//   },
// )
// // import 'package:flutter/material.dart';

// // Exemple de base de données simulée
// final List<Tache> tachesDB = [
//   Tache(id: '1', nom: 'Nettoyer', imageUrl: 'https://via.placeholder.com/150'),
//   Tache(id: '2', nom: 'Cuisiner', imageUrl: 'https://via.placeholder.com/150'),
// ];

// class TachesPage extends StatelessWidget {
//   const TachesPage({Key? key}) : super(key: key);

//   void _showTacheDialog(BuildContext context, Tache tache) {
//     final TextEditingController controller = TextEditingController();
//     String? errorMessage;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: Text('Quel est le nom de l\'objet ?'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.network(
//                   tache.imageUrl,
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
//                   loadingBuilder: (context, child, progress) {
//                     if (progress == null) return child;
//                     return const CircularProgressIndicator();
//                   },
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: controller,
//                 decoration: InputDecoration(
//                   labelText: 'Nom de l\'objet',
//                   errorText: errorMessage,
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 String saisie = controller.text.trim();

//                 if (saisie.isEmpty) {
//                   setState(() {
//                     errorMessage = 'Veuillez entrer un nom.';
//                   });
//                 } else if (saisie.toLowerCase() == tache.nom.toLowerCase()) {
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('✅ Bravo, bonne réponse !')),
//                   );
//                 } else {
//                   setState(() {
//                     errorMessage = '❌ Mauvaise réponse.';
//                   });
//                 }
//               },
//               child: const Text('Valider'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Annuler'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Liste des tâches')),
//       body: ListView.builder(
//         itemCount: tachesDB.length,
//         itemBuilder: (context, index) {
//           final tache = tachesDB[index];
//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             child: ListTile(
//               title: Text('Tâche #${tache.id}'),
//               trailing: const Icon(Icons.arrow_forward_ios),
//               onTap: () => _showTacheDialog(context, tache),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
