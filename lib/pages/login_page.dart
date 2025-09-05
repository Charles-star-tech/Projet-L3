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
import 'package:flutter/foundation.dart' show kIsWeb;

//final GoogleSignIn googleSignIn = GoogleSignIn.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb
      ? "TON_CLIENT_ID_WEB.apps.googleusercontent.com"
      : null, // pour Android pas besoin
);


class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initGoogleSignIn();
  }

  // Future<void> initGoogleSignIn() async {
  //   if (!googleSignIn.isInitialized) {
  //     await googleSignIn.initialize(
  //       clientId: kIsWeb ? 'TON_CLIENT_ID_WEB.apps.googleusercontent.com' : null,
  //       serverClientId: kIsWeb ? null : 'TON_SERVER_CLIENT_ID',
  //     );
  //   }
  // }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Connexion annulée.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final currentUser = FirebaseAuth.instance.currentUser;
      print("Connecté via Google : ${currentUser?.displayName} (${currentUser?.email})");
    } catch (e) {
      print("Erreur Google Sign-In : $e");
      showErrorMessage("Erreur Google Sign-In : $e");
      return;
    }
  }


  void signUserIn() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      showErrorMessage("${e.code} - ${e.message}");
    } finally {
      Navigator.pop(context);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      print("Erreur Apple Sign-In: $e");
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        print("Login Facebook annulé ou erreur : ${result.message}");
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text('Bienvenue',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                const SizedBox(height: 25),
                MyTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: 'Email',
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  controller: passwordController,
                  obscureText: true,
                  hintText: 'Password',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Mot de passe oublié',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(text: "Se connecter", onTap: signUserIn),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(children: [
                    Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Text('Continuer avec',
                          style: TextStyle(color: Colors.green[500])),
                    ),
                    Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400])),
                  ]),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'assets/images/facebook.png',
                      onTap: () async {
                        await signInWithFacebook();
                      },
                    ),
                    const SizedBox(width: 25),
                    SquareTile(
                      imagePath: 'assets/images/google.png',
                      onTap: () async {
                        await signInWithGoogle();
                      },
                    ),
                    const SizedBox(width: 25),
                    SquareTile(
                      imagePath: 'assets/images/apple.png',
                      onTap: () async {
                        await signInWithApple();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("J'ai pas de compte", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text("s'inscrire",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
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