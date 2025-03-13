
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:chat_app/screens/signin_screen.dart';
import 'package:chat_app/screens/page_accueil.dart';


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

  // Parcours universel à ajouter
  Map<String, dynamic> universalCourse = {
    'title': "Présentation du projet GéarArt",
    'imageUrl': "https://via.placeholder.com/150",
    'createdAt': Timestamp.now(),
    'section': "Art Is TIC",
    'accessKey': "S037GMFM",
    'points': 0,
    'status': false,
  };

  if (!userDoc.exists) {
    // 🔹 Si l'utilisateur n'existe pas encore, on l'initialise avec le parcours universel
    await userRef.set({
      'points': 0,
      'pseudo': _pseudoController.text.trim(), //  Ajout du pseudo
      'collections': {
        'Art Is TIC': {'030': universalCourse},
      },
      'joinedCourses': [], // 🔹 On ne met pas encore le parcours universel ici
    });

    // 🔹 Maintenant, on l'ajoute à la fin de la liste
    await userRef.update({
      "joinedCourses": FieldValue.arrayUnion(["030"]),
    });

  } else {
    // 🔹 Vérifier si l'utilisateur a déjà ce parcours universel
    Map<String, dynamic>? collections = userDoc.data()?["collections"];
    List<dynamic> joinedCourses = userDoc.data()?["joinedCourses"] ?? [];

    if (collections == null || !collections.containsKey("Art Is TIC") || !collections["Art Is TIC"].containsKey("030")) {
      // 🔹 Mise à jour de la collection en ajoutant le parcours universel
      await userRef.update({
        "collections.Art Is TIC.030": universalCourse,
      });

      // 🔹 Ajouter l'ID du parcours universel **en dernier**
      joinedCourses.add("030");
      await userRef.update({
        "joinedCourses": joinedCourses,
      });
    }
      if (!userDoc.data()!.containsKey("pseudo")) {
      await userRef.update({
        'pseudo': _pseudoController.text.trim(),
      });
    }
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
void _navigateToHome() {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()), // Passer l'utilisateur
    );
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
                    const Text('Je confirme avoir lu les CGU', style: TextStyle(color: Colors.white)),
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
                  onTap: () {
 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );

                  },
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
