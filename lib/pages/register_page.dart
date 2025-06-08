import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //controlleur de saisi de text
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign user in method
  void signUserUp() async {

    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator(),
        );
      },
    );
    //try sign in
    try {
      //verifier si le mot de passe est correct
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        //show message d'erreur
        showErrorMessage("Mot de passe pas correct");
      }
      //pop the navigation
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the navigation
      Navigator.pop(context);
      //show erreur message
      showErrorMessage(e.code);
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
  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn;

      if (kIsWeb) {
        // 👇 Pour le Web uniquement : spécifie le clientId Web
        googleSignIn = GoogleSignIn(
          clientId: 'TON_CLIENT_ID_WEB.apps.googleusercontent.com',
        );
      } else {
        // 👇 Pour Android/iOS : pas besoin de clientId
        googleSignIn = GoogleSignIn();
      }

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
                const SizedBox(height: 25),

                //logo
                const Icon(
                  Icons.lock,
                  size: 50,
                ),

                const SizedBox(height: 25),

                //Le texte de bienvenu
                Text(
                  'Vous pouvez créer un compte',
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
                  hintText: 'Mot de passe',
                ),

                //confimez le mot de passse
                MyTextfield(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: 'Confirmez le mot de passe',
                ),

                const SizedBox(height: 25),

                //sign in button

                MyButton(
                  text: 'se connecter',
                  onTap: signUserUp,
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
                    SquareTile(imagePath: 'assets/images/apple.png'),
                  ],
                ),

                const SizedBox(height: 50),

                //not a member? registre now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "J'ai un compte",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "S'inscrire",
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

