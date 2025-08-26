import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tutore_vrais/components/my_button.dart';
import 'package:tutore_vrais/components/my_textfield.dart';
import 'package:tutore_vrais/components/square_tile.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


  // Génère un nonce aléatoire sécurisé
class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//Cette classe gère la page de connexion
class _LoginPageState extends State<LoginPage> {

  //controlleur de saisi de text
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {

    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      //pop the navigation
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the navigation
      Navigator.pop(context);
      //show erreur message
      showErrorMessage("${e.code} - ${e.message}");
      //showErrorMessage(e.code);
    }
  }

  //message d'erreur
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
    );
  }

  //connection avec Google
  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn;

      if (kIsWeb) {
        // Pour le Web uniquement : spécifie le clientId Web
        googleSignIn = GoogleSignIn(
          clientId: 'TON_CLIENT_ID_WEB.apps.googleusercontent.com',
        );
      } else {
        // Pour Android/iOS : pas besoin de clientId
        googleSignIn = GoogleSignIn();
      }

      //Déconnecter tout compte Google déjà connecté pour forcer la sélection d’un compte
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // L'utilisateur a annulé

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // Hash SHA-256 du nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  //connection avec Apple (facultatif)
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
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

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

  // Affiche le dialogue pour la tâche sélectionnée
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const SizedBox(height: 50),

                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                //Le texte de bienvenu
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //email textfield
                MyTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: 'Email',
                ),


                const SizedBox(height: 10),

                //password textfield
                MyTextfield(
                  controller: passwordController,
                  obscureText: true,
                  hintText: 'Password',
                ),

                //forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Mot de passe oublier',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //sign in button

                MyButton(
                  text: "Se connecter",
                  onTap: signUserIn,
                ),

                const SizedBox(height: 50),


                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70.0),
                        child: Text(
                          'Continuer avec',
                          style: TextStyle(color: Colors.green[500]),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          )
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                //google + apple sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //facebook button
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

                    //google button
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

                    SizedBox(width: 25),

                    //apple button
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

                //not a member? registre now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "J'ai pas de compt",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "s'inscrire",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
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
