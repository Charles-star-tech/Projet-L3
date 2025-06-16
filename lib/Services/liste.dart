body: _items.isEmpty
? Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.admin_panel_settings,
size: 80,
color: Colors.grey[400],
),
SizedBox(height: 16),
Text(
'Bienvenue, Administrateur!',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.grey[600],
),
),
SizedBox(height: 8),
Text(
'Aucune tâche ajoutée pour le moment',
style: TextStyle(fontSize: 16, color: Colors.grey[500]),
),
SizedBox(height: 20),
ElevatedButton.icon(
onPressed: _showAddMenu,
icon: Icon(Icons.add),
label: Text('Ajouter une tâche'),
),
],
),
)
    : ListView.builder(
padding: EdgeInsets.all(16),
itemCount: _items.length,
itemBuilder: (context, index) {
final item = _items[index];
return Card(
margin: EdgeInsets.only(bottom: 12),
elevation: 2,
child: ListTile(
leading: CircleAvatar(
backgroundColor: Colors.blue,
child: Text(
'${index + 1}',
style: TextStyle(color: Colors.white),
),
),
title: Text(
item['task']!,
style: TextStyle(fontWeight: FontWeight.bold),
),
subtitle: Text(
'Mot: ${item['word']}',
style: TextStyle(color: Colors.grey[600]),
),
trailing: IconButton(
onPressed: () => _deleteItem(index),
icon: Icon(Icons.delete, color: Colors.red),
),
),
);
},
),