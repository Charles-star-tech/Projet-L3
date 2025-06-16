import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 🔁 Fonction d'inscription
  void signUserUp() async {
    // 🔁 Affiche un indicateur de chargement
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // ✳️ Vérifie les champs
    if (nameController.text.trim().isEmpty) {
      Navigator.pop(context);
      return showErrorMessage("Veuillez entrer votre nom");
    }

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      return showErrorMessage("Les mots de passe ne correspondent pas");
    }

    try {
      // 🔐 Crée le compte utilisateur
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 💾 Ajoute les infos dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user', // 👈 Tu peux changer ce rôle par défaut si nécessaire
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.message ?? "Erreur inconnue");
    }
  }

  // ⚠️ Affiche une erreur
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // 👉 Connexion avec Google (facultatif)
  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
          clientId: 'TON_CLIENT_ID_WEB.apps.googleusercontent.com')
          : GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      showErrorMessage("Erreur Google Sign-In : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                const Icon(Icons.lock, size: 50),
                const SizedBox(height: 25),
                Text(
                  'Vous pouvez créer un compte',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),

                // 🔹 Champ nom
                MyTextfield(
                  controller: nameController,
                  obscureText: false,
                  hintText: 'Nom',
                ),
                const SizedBox(height: 25),

                // 🔹 Champ email
                MyTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: 'Email',
                ),
                const SizedBox(height: 10),

                // 🔹 Mot de passe
                MyTextfield(
                  controller: passwordController,
                  obscureText: true,
                  hintText: 'Mot de passe',
                ),
                const SizedBox(height: 10),

                // 🔹 Confirmation mot de passe
                MyTextfield(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: 'Confirmez le mot de passe',
                ),
                const SizedBox(height: 25),

                // 🔘 Bouton s'inscrire
                MyButton(
                  text: 'S\'inscrire',
                  onTap: signUserUp,
                ),
                const SizedBox(height: 50),

                // 🔻 Texte "ou continuer avec"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(children: [
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Continuer avec',
                          style: TextStyle(color: Colors.green[500])),
                    ),
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                  ]),
                ),

                const SizedBox(height: 50),

                // 🔘 Boutons Google et Apple
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'assets/images/google.png',
                      onTap: () async {
                        try {
                          await signInWithGoogle();
                        } catch (e) {
                          print("Erreur Google Sign-In: $e");
                        }
                      },
                    ),
                    const SizedBox(width: 25),
                    SquareTile(imagePath: 'assets/images/apple.png'),
                  ],
                ),
                const SizedBox(height: 50),

                // 🔹 Lien pour aller à la page de login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("J'ai déjà un compte", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
