import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // 🔔 Activation/Désactivation des notifications
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text("Recevoir des rappels et alertes"),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // 🔁 Ici tu peux sauvegarder dans les préférences ou Firebase
              });
            },
          ),

          // 🌙 Mode sombre
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text("Activer le thème sombre"),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // 👉 Tu peux appeler ici un ThemeNotifier pour changer dynamiquement
              });
            },
          ),

          // 🌍 Choix de la langue
          ListTile(
            title: const Text('Langue'),
            subtitle: Text("Langue actuelle : $_language"),
            trailing: DropdownButton<String>(
              value: _language,
              items: ['Français', 'Mooré']
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) _language = value;
                  // 👉 Tu peux gérer la traduction ici (ex: avec easy_localization)
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
