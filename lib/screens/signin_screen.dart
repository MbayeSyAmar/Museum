
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
