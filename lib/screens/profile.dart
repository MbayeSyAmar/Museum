import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/signin_screen.dart';

class ProfilApp extends StatefulWidget {
  const ProfilApp({Key? key}) : super(key: key);

  @override
  State<ProfilApp> createState() => ProfilScreen();
}

class ProfilScreen extends State<ProfilApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _user;
  late Stream<DocumentSnapshot> _userStream;
  int highestPoints = 0; //  Stocke le score max
  double progressBarWidth = 0.0; //  Défini avec une valeur par défaut
  int currentLevel = 1; //  Niveau initial




  @override
  void initState() {
    super.initState();
     _loadUserData();
     if (_user != null) {
    _findMaxPoints(); //  Mettre à jour les points en temps réel
  }
    _user = _auth.currentUser;
  }
void _loadUserData() {
    _user = _auth.currentUser; // Récupère l'utilisateur connecté
    if (_user != null) {
      setState(() { //  Force la mise à jour de l'UI après récupération des données
        _userStream = _firestore.collection('users').doc(_user!.uid).snapshots();
      });
       _findMaxPoints(); //  Récupère le score max après avoir chargé les données
    }
  }
  int calculateLevel(int points) {
    return (points / 10).floor() + 1;
  }

  int calculateRemainingXP(int points) {
    return 10 - (points % 10);
  }

  Future<void> _modifyUserInfo() async {
    // Implement the logic to modify user information
    // You can use a dialog or navigate to a new screen for editing
  }

  Future<void> _resetCollection() async {
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
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
        'points': 0,
      });
      setState(() {}); // Refresh the UI
    } catch (e) {
      print('Error resetting collection: $e');
    }
  }

Future<void> _deleteAccount() async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
        actions: <Widget>[
          TextButton(
            child: Text('Non'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Oui'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userEmail = user.email!;

        //  Étape 1 : Supprimer les données Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        print(" Données Firestore supprimées.");

        //  Étape 2 : Déconnecter et rediriger AVANT la suppression du compte
        await _auth.signOut();
        // Navigator.of(context).pushReplacementNamed('/login');
        Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
        //  Étape 3 : Authentification récente nécessaire ?
        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: userEmail,
            password: "VOTRE_MOT_DE_PASSE_UTILISATEUR", //  Remplace par une saisie utilisateur
          );

          await user.reauthenticateWithCredential(credential);
          print(" Authentification rafraîchie.");
        } catch (e) {
          print(" Impossible de rafraîchir l'authentification : $e");
          return;
        }

        //  Étape 4 : Supprimer l'utilisateur de Firebase Auth
        await user.delete();
        print(" Compte supprimé de Firebase Auth.");
      }
    } catch (e) {
      print(' Erreur lors de la suppression du compte : $e');
    }
  }
}


void _findMaxPoints() {
  if (_user == null) return;

  _firestore.collection('users').doc(_user!.uid).snapshots().listen((userDoc) {
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('collections')) {
        Map<String, dynamic> collections = userData['collections'];

        int maxPoints = 0;

        collections.forEach((collectionName, images) {
          if (images is Map<String, dynamic>) {
            images.forEach((imageId, imageData) {
              if (imageData is Map<String, dynamic> && imageData.containsKey('points')) {
                int points = imageData['points'] ?? 0;
                if (points > maxPoints) {
                  maxPoints = points;
                }
              }
            });
          }
        });
        if (!mounted) return;
        setState(() {
          highestPoints = maxPoints;
          currentLevel = (highestPoints / 10).floor() + 1;
          progressBarWidth = (highestPoints % 10) / 10.0;

          //  S'assurer que la barre ne soit jamais totalement vide
          if (progressBarWidth == 0.0 && highestPoints > 0) {
            progressBarWidth = 0.1;
          }

          progressBarWidth = progressBarWidth.clamp(0.1, 1.0);
        });

        print(" Niveau : $currentLevel | XP total : $highestPoints | Barre XP : $progressBarWidth");
      }
    }
  });
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _userStream == null
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              //  Vérifie si les données sont disponibles
              if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Chargement des données...",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              //  Vérifie si l'utilisateur a été supprimé
              var userData = snapshot.data!.data();
              if (userData == null) {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pushReplacementNamed('/login');
                });

                return Center(
                  child: Text(
                    "Compte supprimé. Redirection...",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              }

              //  Convertir en Map de manière sécurisée
              Map<String, dynamic> userMap = userData as Map<String, dynamic>;

              String pseudo = userMap['pseudo'] ?? 'Utilisateur';
              int points = highestPoints;
              int level = calculateLevel(points);
              int remainingXP = calculateRemainingXP(points);

              print(" Nouveaux points détectés : $highestPoints");
              print(" Nouvelle largeur de la barre : $progressBarWidth");

              return Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/image1.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: const Color(0xFF00292A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          Text(
                            pseudo.toUpperCase(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Arcane Nine',
                            ),
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Niveau $level",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Coolvetica',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progressBarWidth,
                                  child: Container(
                                    height: 22,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF5AB2FF), Color(0xFF007AFF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "${highestPoints % 10} XP",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Coolvetica',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Plus que ${remainingXP}XP pour le niveau suivant !",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Coolvetica',
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Mon compte",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Coolvetica',
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            height: 2,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          buildProfilButton(
                            text: "Modifier mes informations",
                            borderColor: const Color(0xFFB7D6DD),
                            textColor: const Color(0xFFB7D6DD),
                            onPressed: _modifyUserInfo,
                          ),
                          const SizedBox(height: 15),
                          buildProfilButton(
                            text: "Réinitialiser la collection",
                            borderColor: const Color(0xFFED254E),
                            textColor: const Color(0xFFED254E),
                            onPressed: _resetCollection,
                          ),
                          const SizedBox(height: 15),
                          buildProfilButton(
                            text: "Supprimer mon compte",
                            borderColor: const Color(0xFFED254E),
                            textColor: const Color(0xFFED254E),
                            onPressed: _deleteAccount,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
  );
}


  // Fonction pour créer les boutons du profil (modifiée pour inclure onPressed)
  Widget buildProfilButton({
    required String text,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: textColor,
              fontFamily: 'Coolvetica',
            ),
          ),
        ),
      ),
    );
  }
}