import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:chat_app/widgets/custom_scaffold.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Champs pour Email et Mot de passe
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Méthode pour initialiser l'utilisateur dans Firestore
  Future<void> _initializeUserInFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      // Crée un nouveau document utilisateur s'il n'existe pas encore
      await userRef.set({
        'points': 0,
        'collections': {
          'Impressionnistes': {
            '001': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '002': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '003': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '004': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '005': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '006': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '007': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '008': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
          },
          'Stone & Cool': {
          '001': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '002': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '003': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '004': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '005': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '006': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '007': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
            '008': {
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
            },
          },
        },
      });
    }
  }

  // Connexion avec Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // L'utilisateur a annulé la connexion
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _initializeUserInFirestore(user); // Initialiser Firestore
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Accueil()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion Google échouée : $e')),
      );
    }
  }

  // Connexion avec Email et Mot de passe
  Future<void> _signInWithEmailAndPassword() async {
    if (_formSignInKey.currentState!.validate()) {
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final User? user = userCredential.user;

        if (user != null) {
          await _initializeUserInFirestore(user); // Initialiser Firestore
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Accueil()),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur d\'authentification'),
            content: const Text(
                'L\'email ou le mot de passe est incorrect. Veuillez réessayer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bon retour',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Entrez votre email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                            fontFamily: 'Cinzel',
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Mot de passe'),
                          hintText: 'Entrez votre mot de passe',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                            fontFamily: 'Cinzel',
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Se souvenir de moi',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontFamily: 'Cinzel',
                                ),
                              ),
                            ],
                          ),
                          // GestureDetector(
                          //   child: Text(
                          //     'Mot de passe oublié ?',
                          //     style: TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       color: lightColorScheme.primary,
                          //       fontFamily: 'Cinzel',
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          child: const Text('Connexion'),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Se connecter avec',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            // onTap: _signInWithFacebook,
                            child: Logo(Logos.facebook_f),
                          ),
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Logo(Logos.google),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pas encore de compte ? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Inscription',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
