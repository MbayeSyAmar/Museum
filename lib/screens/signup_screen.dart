// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:chat_app/screens/signin_screen.dart';
// import 'package:chat_app/theme/theme.dart';
// import 'package:chat_app/widgets/custom_scaffold.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formSignupKey = GlobalKey<FormState>();
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool agreePersonalData = true;

//   // Firebase Authentication instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Initialiser les données utilisateur dans Firestore
//   Future<void> _initializeUserInFirestore(User user) async {
//     final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

//     final userDoc = await userRef.get();
//     if (!userDoc.exists) {
//       // Crée un nouveau document utilisateur s'il n'existe pas encore
//       await userRef.set({
//         'fullName': _fullNameController.text.trim(), // Stockage du nom complet
//         'points': 0,
//         'collections': {
//           'Impressionnistes': {
//             '001': {
//               'titre' : "Joconde",
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '002': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '003': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '004': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '005': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '006': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '007': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '008': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//           },
//           'Stone & Cool': {
//             '001': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '002': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '003': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '004': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '005': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '006': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '007': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//             '008': {
//               'url': "assets/images/background_hint.png",
//               'points': 0,
//               'status': false,
//               'description': 'Un indice pour cette image',
//             },
//           },
//         },
//       });
//     }
//   }

//   // Fonction pour s'inscrire avec email et mot de passe
//   Future<void> _signUpWithEmailAndPassword() async {
//     if (_formSignupKey.currentState!.validate() && agreePersonalData) {
//       try {
//         final userCredential = await _auth.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         final User? user = userCredential.user;
//         await user?.updateDisplayName(_fullNameController.text);

//         if (user != null) {
//           await _initializeUserInFirestore(user); // Initialiser Firestore
//         }

//         // Affiche une boîte de dialogue de succès
//         await _showSuccessDialog();
//       } on FirebaseAuthException catch (e) {
//         _showErrorSnackBar(e.message ?? 'Une erreur s\u2019est produite.');
//       }
//     } else if (!agreePersonalData) {
//       _showErrorSnackBar('Veuillez accepter le traitement des données personnelles.');
//     }
//   }

//   // Fonction pour s'inscrire avec Google
//   Future<void> _signUpWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;

//       if (user != null) {
//         await _initializeUserInFirestore(user); // Initialiser Firestore
//       }

//       // Affiche une boîte de dialogue de succès
//       await _showSuccessDialog();
//     } on FirebaseAuthException catch (e) {
//       _showErrorSnackBar(e.message ?? 'Une erreur s\u2019est produite.');
//     }
//   }

//   // Montre une boîte de dialogue en cas de succès
//   Future<void> _showSuccessDialog() async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Succès'),
//           content: const Text(
//               'Inscription réussie. Cliquez sur OK pour accéder à l\u2019application.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Ferme la boîte de dialogue
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SignInScreen(),
//                   ),
//                 );
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Montre une barre de message d'erreur
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       child: Column(
//         children: [
//           const Expanded(
//             flex: 1,
//             child: SizedBox(height: 10),
//           ),
//           Expanded(
//             flex: 10,
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
//                   key: _formSignupKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Commencer',
//                         style: TextStyle(
//                           fontSize: 30.0,
//                           fontWeight: FontWeight.w900,
//                           color: lightColorScheme.primary,
//                           fontFamily: 'Cinzel',
//                         ),
//                       ),
//                       const SizedBox(height: 40.0),
//                       TextFormField(
//                         controller: _fullNameController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Veuillez entrer un nom complet';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           label: const Text('Nom complet'),
//                           hintText: 'Entrez votre nom complet',
//                           hintStyle: const TextStyle(
//                             color: Colors.black26,
//                             fontFamily: 'Cinzel',
//                           ),
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(color: Colors.black12),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 25.0),
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
//                             borderSide: const BorderSide(color: Colors.black12),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 25.0),
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
//                             borderSide: const BorderSide(color: Colors.black12),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 25.0),
//                       Row(
//                         children: [
//                           Checkbox(
//                             value: agreePersonalData,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 agreePersonalData = value!;
//                               });
//                             },
//                             activeColor: lightColorScheme.primary,
//                           ),
                          
//                           Text(
//                             'données personnelles',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: lightColorScheme.primary,
//                               fontFamily: 'Cinzel',
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 25.0),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _signUpWithEmailAndPassword,
//                           child: const Text('S\u2019inscrire'),
//                         ),
//                       ),
//                       const SizedBox(height: 30.0),
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
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                             child: Text(
//                               'S\u2019inscrire avec',
//                               style: TextStyle(color: Colors.black45),
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
//                       const SizedBox(height: 30.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           GestureDetector(
//                             // Ajoutez la logique Facebook
//                             child: Logo(Logos.facebook_f),
//                           ),
//                           Logo(Logos.twitter), // Ajoutez la logique Twitter
//                           GestureDetector(
//                             onTap: _signUpWithGoogle,
//                             child: Logo(Logos.google),
//                           ),
//                           Logo(Logos.apple), // Ajoutez la logique Apple
//                         ],
//                       ),
//                       const SizedBox(height: 25.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Vous avez déjà un compte ? ',
//                             style: TextStyle(color: Colors.black45),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (e) => const SignInScreen(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'Se connecter',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: lightColorScheme.primary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20.0),
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



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_plus/icons_plus.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptCGU = false;

  final _formSignupKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Initialisation de l'utilisateur dans Firestore
  Future<void> _initializeUserInFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'pseudo': _pseudoController.text.trim(), // Stockage du pseudo
        'points': 0,
        'collections': {
          'Impressionnistes': {
            '001': {'url': "assets/images/background_hint.png", 'points': 0, 'status': false, 'description': 'Un indice pour cette image'},
            '002': {'url': "assets/images/background_hint.png", 'points': 0, 'status': false, 'description': 'Un indice pour cette image'},
          },
          'Stone & Cool': {
            '001': {'url': "assets/images/background_hint.png", 'points': 0, 'status': false, 'description': 'Un indice pour cette image'},
            '002': {'url': "assets/images/background_hint.png", 'points': 0, 'status': false, 'description': 'Un indice pour cette image'},
          },
        },
      });
    }
  }

  // Inscription avec Email et Mot de passe
  Future<void> _signUpWithEmailAndPassword() async {
    if (_formSignupKey.currentState!.validate() && _acceptCGU) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User? user = userCredential.user;
        await user?.updateDisplayName(_pseudoController.text);

        if (user != null) {
          await _initializeUserInFirestore(user);
        }

        await _showSuccessDialog();
      } catch (e) {
        _showErrorSnackBar(e.toString());
      }
    } else if (!_acceptCGU) {
      _showErrorSnackBar('Veuillez accepter les CGU.');
    }
  }

  // Inscription avec Google
  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _initializeUserInFirestore(user);
      }

      await _showSuccessDialog();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text("Inscription réussie."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
Widget buildTextField(
  String labelText,
  TextEditingController controller,
  bool isPassword,
  VoidCallback? togglePasswordVisibility, [
  bool obscureText = false,
]) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword ? obscureText : false,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70, width: 1.5), // Bordure normale
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.cyan, width: 2.5), // Bordure cyan épaisse quand focus
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: togglePasswordVisibility,
            )
          : null,
    ),
    cursorColor: Colors.cyan, // Curseur cyan pour un meilleur effet
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Veuillez entrer $labelText';
      }
      return null;
    },
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView( // Ajout du défilement
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formSignupKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text("Nouveau compte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),

                buildTextField("Pseudo", _pseudoController, false, null),
                const SizedBox(height: 15),
                buildTextField("E-mail", _emailController, false, null),
                const SizedBox(height: 15),
                buildTextField("Mot de passe", _passwordController, true, () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                }, _obscurePassword),
                const SizedBox(height: 15),
                buildTextField("Confirmer le mot de passe", _confirmPasswordController, true, () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                }, _obscureConfirmPassword),

                const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptCGU,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptCGU = value!;
                        });
                      },
                      activeColor: Colors.yellow,
                    ),
                    const Text('✓ Je confirme avoir lu les CGU', style: TextStyle(color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signUpWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _acceptCGU ? const Color(0xFFFFDB3D) : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Créer un compte", style: TextStyle(color: Color(0xFF00292A), fontSize: 22, fontWeight: FontWeight.bold)),
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
                  onTap: _signUpWithGoogle,
                  child: Logo(Logos.google),
                ),

                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {},
                  child: const Text("Déjà un compte ? Se connecter", style: TextStyle(color: Colors.yellow, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}
