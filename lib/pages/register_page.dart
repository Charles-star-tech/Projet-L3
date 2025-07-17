import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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
            'role': 'user', // Tu peux changer ce rôle par défaut si nécessaire
            'createdAt': FieldValue.serverTimestamp(),
          });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.message ?? "Erreur inconnue");
    }
  }

  // Affiche une erreur
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

  // Connexion avec Google (facultatif)
  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId: 'TON_CLIENT_ID_WEB.apps.googleusercontent.com',
            )
          : GoogleSignIn();

      // Déconnecter tout compte Google déjà connecté pour forcer la sélection d’un compte
      await googleSignIn.signOut();

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

  // Génère un nonce aléatoire pour l'authentification Apple
  // Génère un nonce aléatoire sécurisé
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // Hash SHA-256 du nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    try {
      // Crée un nonce aléatoire (sécurisé)
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Démarre l'authentification Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Crée les identifiants Firebase à partir d'Apple
      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Authentifie l'utilisateur avec Firebase
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      // Gestion des erreurs
      print("Erreur Apple Sign-In: $e");
    }
  }

  //Connetion avec Facebook (facultatif)
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        final credential = FacebookAuthProvider.credential(accessToken!.tokenString);

        await FirebaseAuth.instance.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        print("Connexion Facebook annulée.");
      } else {
        print("Erreur Facebook : ${result.message}");
      }
    } catch (e) {
      print("Erreur Facebook Sign-In : $e");
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
                const SizedBox(height: 10),

                // Champ email
                MyTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: 'Email',
                ),
                const SizedBox(height: 10),

                // Mot de passe
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
                MyButton(text: 'S\'inscrire', onTap: signUserUp),
                const SizedBox(height: 50),

                // Texte "ou continuer avec"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Continuer avec',
                          style: TextStyle(color: Colors.green[500]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // 🔘 Boutons Google et Apple
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton Facebook
                    SquareTile(
                      imagePath: 'assets/images/facebook.png',
                      onTap: () async {
                        try {
                          await signInWithFacebook();
                        } catch (e) {
                          print("Erreur Facebook Sign-In: $e");
                        }
                      },
                    ),
                    SizedBox(width: 25),
                    // Bouton Google
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
                    // Bouton Apple
                    SquareTile(
                      imagePath: 'assets/images/apple.png',
                      onTap: () async {
                        try {
                          await signInWithApple();
                        } catch (e) {
                          print("Erreur Apple Sign-In: $e");
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // 🔹 Lien pour aller à la page de login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "J'ai déjà un compte",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
