// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:chat_app/screens/signup_screen.dart';
// import 'package:chat_app/widgets/custom_scaffold.dart';
// import 'package:chat_app/screens/page_accueil.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import '../theme/theme.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final _formSignInKey = GlobalKey<FormState>();
//   bool rememberPassword = true;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Champs pour Email et Mot de passe
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // Méthode pour initialiser l'utilisateur dans Firestore
//   Future<void> _initializeUserInFirestore(User user) async {
//     final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

//     final userDoc = await userRef.get();
//     if (!userDoc.exists) {
//       // Crée un nouveau document utilisateur s'il n'existe pas encore
//       await userRef.set({
//         'points': 0,
//         'collections': {
//           'Impressionnistes': {
//             '001': {
//               'titre' : "Joconde",
                  // 'musee' : "Louvre",
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '002': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '003': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '004': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '005': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '006': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '007': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '008': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//           },
//           'Stone & Cool': {
//           '001': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '002': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '003': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '004': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '005': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '006': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '007': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '008': {
//               'url': "assets/images/background_hint.png",
//               'points' : 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//           },
//         },
//       });
//     }
//   }

//   // Connexion avec Google
//   Future<void> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         return; // L'utilisateur a annulé la connexion
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;

//       if (user != null) {
//         await _initializeUserInFirestore(user); // Initialiser Firestore
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Accueil()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Connexion Google échouée : $e')),
//       );
//     }
//   }

//   // Connexion avec Email et Mot de passe
//   Future<void> _signInWithEmailAndPassword() async {
//     if (_formSignInKey.currentState!.validate()) {
//       try {
//         final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//         final User? user = userCredential.user;

//         if (user != null) {
//           await _initializeUserInFirestore(user); // Initialiser Firestore
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Accueil()),
//           );
//         }
//       } catch (e) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Erreur d\'authentification'),
//             content: const Text(
//                 'L\'email ou le mot de passe est incorrect. Veuillez réessayer.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       child: Column(
//         children: [
//           const Expanded(
//             flex: 1,
//             child: SizedBox(
//               height: 10,
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40.0),
//                   topRight: Radius.circular(40.0),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formSignInKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Bon retour',
//                         style: TextStyle(
//                           fontSize: 30.0,
//                           fontWeight: FontWeight.w900,
//                           color: lightColorScheme.primary,
//                           fontFamily: 'Cinzel',
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 40.0,
//                       ),
//                       TextFormField(
//                         controller: _emailController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Veuillez entrer un email';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           label: const Text('Email'),
//                           hintText: 'Entrez votre email',
//                           hintStyle: const TextStyle(
//                             color: Colors.black26,
//                             fontFamily: 'Cinzel',
//                           ),
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.black12,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.black12,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         obscuringCharacter: '*',
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Veuillez entrer un mot de passe';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           label: const Text('Mot de passe'),
//                           hintText: 'Entrez votre mot de passe',
//                           hintStyle: const TextStyle(
//                             color: Colors.black26,
//                             fontFamily: 'Cinzel',
//                           ),
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.black12,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.black12,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: rememberPassword,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     rememberPassword = value!;
//                                   });
//                                 },
//                                 activeColor: lightColorScheme.primary,
//                               ),
//                               const Text(
//                                 'Se souvenir de moi',
//                                 style: TextStyle(
//                                   color: Colors.black45,
//                                   fontFamily: 'Cinzel',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // GestureDetector(
//                           //   child: Text(
//                           //     'Mot de passe oublié ?',
//                           //     style: TextStyle(
//                           //       fontWeight: FontWeight.bold,
//                           //       color: lightColorScheme.primary,
//                           //       fontFamily: 'Cinzel',
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _signInWithEmailAndPassword,
//                           child: const Text('Connexion'),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               thickness: 0.7,
//                               color: Colors.grey.withOpacity(0.5),
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.symmetric(
//                               vertical: 0,
//                               horizontal: 10,
//                             ),
//                             child: Text(
//                               'Se connecter avec',
//                               style: TextStyle(
//                                 color: Colors.black45,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               thickness: 0.7,
//                               color: Colors.grey.withOpacity(0.5),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           GestureDetector(
//                             // onTap: _signInWithFacebook,
//                             child: Logo(Logos.facebook_f),
//                           ),
//                           GestureDetector(
//                             onTap: _signInWithGoogle,
//                             child: Logo(Logos.google),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 25.0,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Pas encore de compte ? ',
//                             style: TextStyle(
//                               color: Colors.black45,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (e) => const SignUpScreen(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'Inscription',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: lightColorScheme.primary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 20.0,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ///////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:icons_plus/icons_plus.dart';




class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}


class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? "";
        _passwordController.text = prefs.getString('password') ?? "";
      }
    });
  }

  Future<void> _saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> _initializeUserInFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'points': 0,
        'collections': {
          'Impressionnistes': {'001':
           {'titre' : "Joconde",
                  'musee' : "Louvre",
              'url': "assets/images/background_hint.png",
              'points' : 0,
              'status': false,
              'description': 'Un indice pour cette image',
              }
              },
          'Stone & Cool': {'001': {'status': false, 'points': 0}},
        },
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _initializeUserInFirestore(user);
        _navigateToHome();
      }
    } catch (e) {
      _showSnackBar("Connexion Google échouée : $e");
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final User? user = userCredential.user;

      if (user != null) {
        await _initializeUserInFirestore(user);
        await _saveUserCredentials(); // Sauvegarde des identifiants si "Se souvenir de moi" est activé
        _navigateToHome();
      }
    } catch (e) {
      _showDialog("Erreur d'authentification", "L'email ou le mot de passe est incorrect.");
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Se connecter",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

             buildTextField("E-mail", false, null),
          const SizedBox(height: 15),
          buildTextField("Mot de passe", true, () {
            setState(() {
            _obscurePassword = !_obscurePassword;
          });
          }),


              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: _rememberMe,
                  //       onChanged: (bool? value) {
                  //         setState(() {
                  //           _rememberMe = value!;
                  //         });
                  //       },
                  //       activeColor: Colors.yellow,
                  //     ),
                  //     const Text(
                  //       'Se souvenir de moi',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 5),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDB3D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(color: Color(0xFF00292A), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white70,
                  thickness: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Via un service",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.white70,
                  thickness: 1,
                ),
              ),
            ],
          ),

              const SizedBox(height: 30),
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: Logo(Logos.google),
                  ),
            ],
          ),
        ),
      ),
    );
  }

Widget buildTextField(String labelText, bool isPassword, VoidCallback? toggleVisibility) {
  return TextFormField(
    controller: isPassword ? _passwordController : _emailController,
    obscureText: isPassword ? _obscurePassword : false,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70, width: 1.5), // Bordure normale blanche
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.cyan, width: 2.5), // Bordure cyan épaisse quand focus
        borderRadius: BorderRadius.circular(10),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    ),
    cursorColor: Colors.cyan, // Curseur cyan pour correspondre au focus
  );
}

}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: Text("Bienvenue !")));
//   }
// }
