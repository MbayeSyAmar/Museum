import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  int highestPoints = 0; // ✅ Stocke le score max
  double progressBarWidth = 0.0; // ✅ Défini avec une valeur par défaut
  int currentLevel = 1; // ✅ Niveau initial




  @override
  void initState() {
    super.initState();
     _loadUserData();
     if (_user != null) {
    _findMaxPoints(); // ✅ Mettre à jour les points en temps réel
  }
    _user = _auth.currentUser;
  }
void _loadUserData() {
    _user = _auth.currentUser; // Récupère l'utilisateur connecté
    if (_user != null) {
      setState(() { // ✅ Force la mise à jour de l'UI après récupération des données
        _userStream = _firestore.collection('users').doc(_user!.uid).snapshots();
      });
       _findMaxPoints(); // ✅ Récupère le score max après avoir chargé les données
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
        String userEmail = user.email!; // 🔥 Récupérer l'email avant suppression

        // 🔥 Étape 1 : Supprimer les données Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        print("✅ Données Firestore supprimées avec succès.");

        // 🔥 Étape 2 : Vérifier si Firebase demande une authentification récente
        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: userEmail,
            password: "VOTRE_MOT_DE_PASSE_UTILISATEUR", // ⚠️ A remplacer par une saisie utilisateur
          );

          await user.reauthenticateWithCredential(credential);
          print("✅ Authentification rafraîchie avec succès.");
        } catch (e) {
          print("⚠️ Impossible de rafraîchir l'authentification : $e");
          return;
        }

        // 🔥 Étape 3 : Supprimer le compte Firebase Authentication
        await user.delete();
        print("✅ Compte supprimé de Firebase Authentication.");

        // 🔥 Étape 4 : Déconnexion et redirection
        await _auth.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du compte : $e');
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

        setState(() {
          highestPoints = maxPoints;
          currentLevel = (highestPoints / 10).floor() + 1;
          progressBarWidth = (highestPoints % 10) / 10.0;

          // ✅ S'assurer que la barre ne soit jamais totalement vide
          if (progressBarWidth == 0.0 && highestPoints > 0) {
            progressBarWidth = 0.1;
          }

          progressBarWidth = progressBarWidth.clamp(0.1, 1.0);
        });

        print("🔥 Niveau : $currentLevel | XP total : $highestPoints | Barre XP : $progressBarWidth");
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : _userStream == null
          ? Center(child: CircularProgressIndicator())
      : StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String pseudo = userData['pseudo'] ?? 'Utilisateur';
          int points = highestPoints; // ✅ On affiche maintenant le maximum des points
          int level = calculateLevel(points);
          int remainingXP = calculateRemainingXP(points);
              // ✅ Vérification si les données changent
    print("🔥 Nouveaux points détectés : $highestPoints"); // ✅ Affiche le max des points
    print("🔥 Nouvelle largeur de la barre : $progressBarWidth"); // ✅ Affiche la largeur de la barre
          return Stack(
            children: [
              // Arrière-plan avec image floutée et dégradé (inchangé)
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

              // Contenu Scrollable
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),

                      // Nom de l'utilisateur (dynamique)
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

                      // Niveau (dynamique)
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

                      // Barre XP stylisée (dynamique)
                   Stack(
  alignment: Alignment.center, // ✅ Garde le texte XP centré
  children: [
    // Fond de la barre XP
    Container(
      width: double.infinity,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    // Barre de progression (mise à jour en fonction de `highestPoints`)
    Align(
      alignment: Alignment.centerLeft, // ✅ La barre commence à gauche
      child: FractionallySizedBox(
        widthFactor: progressBarWidth, // ✅ Dynamique selon les points
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
    // Texte dynamique affichant l'XP restant
    Center(
      child: Text(
        "${highestPoints % 10} XP", // ✅ Affichage dynamique du XP actuel
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

                      // Texte sous la barre XP (dynamique)
                      Text(
                        "Plus que ${remainingXP}XP pour le niveau suivant !",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Coolvetica',
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Titre "Mon Compte"
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

                      // Bouton Modifier mes infos
                      buildProfilButton(
                        text: "Modifier mes informations",
                        borderColor: const Color(0xFFB7D6DD),
                        textColor: const Color(0xFFB7D6DD),
                        onPressed: _modifyUserInfo,
                      ),

                      const SizedBox(height: 15),

                      // Bouton Réinitialiser la collection
                      buildProfilButton(
                        text: "Réinitialiser la collection",
                        borderColor: const Color(0xFFED254E),
                        textColor: const Color(0xFFED254E),
                        onPressed: _resetCollection,
                      ),

                      const SizedBox(height: 15),

                      // Bouton Supprimer mon compte
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