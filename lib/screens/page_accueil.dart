// import 'package:chat_app/screens/music_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_app/screens/page_collection.dart';
// import 'package:chat_app/screens/page_instruction.dart';
// import 'package:chat_app/screens/map_screen.dart';

// class Accueil extends StatefulWidget {
//   const Accueil({super.key});

//   @override
//   State<Accueil> createState() => _AccueilState();
// }

// class _AccueilState extends State<Accueil> {
//   @override
//   void initState() {
//     _stopMusic();
//     super.initState();
//   }

//   Future<void> _stopMusic() async {
//     await MusicManager.stopMusic(); // Arrête la musique via MusicManager
//   }

//   Future<String> _getFirstName() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       String fullName = userDoc['fullName'] ?? "Utilisateur";
//       return fullName.split(" ")[0]; // Retourne le premier prénom
//     }
//     return "Utilisateur";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B2425),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: FutureBuilder<String>(
//                   future: _getFirstName(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return const Center(child: Text("Erreur lors du chargement"));
//                     } else {
//                       return HomeArtGo(firstName: snapshot.data ?? "Utilisateur");
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: BottomNavigationBarCustom(
//               onCalendarPressed: () {
//                 // Ajoutez ici l'action pour le bouton Calendrier
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HomeArtGo extends StatelessWidget {
//   final String firstName;

//   const HomeArtGo({required this.firstName});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: screenHeight * 0.04),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Niveau 1',
//                     style: TextStyle(
//                       fontSize: 23,
//                       fontFamily: 'Coolvetica',
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     firstName,
//                     style: const TextStyle(
//                       fontSize: 23,
//                       fontFamily: 'Coolvetica',
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//              CircleAvatar(
//   radius: 25,
//   backgroundImage: AssetImage("assets/images/background_hint.png"),
// ),

//             ],
//           ),
//           SizedBox(height: screenHeight * 0.03),
//           const Text(
//             'Expositions en cours',
//             style: TextStyle(
//               fontSize: 23,
//               fontFamily: 'Coolvetica',
//               fontWeight: FontWeight.w400,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           Container(
//             width: double.infinity,
//             height: 1,
//             color: Colors.white,
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           const Text(
//             'Voir les évents à venir >',
//             style: TextStyle(
//               fontSize: 15.49,
//               fontFamily: 'Geo',
//               fontWeight: FontWeight.w500,
//               color: Color(0xFFFDFDFD),
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.03),
//           ExhibitionCard(screenWidth: screenWidth, screenHeight: screenHeight),
//           SizedBox(height: screenHeight * 0.03),
//           const Text(
//             'Mes parties',
//             style: TextStyle(
//               fontSize: 23,
//               fontFamily: 'Coolvetica',
//               fontWeight: FontWeight.w400,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           Container(
//             width: double.infinity,
//             height: 1,
//             color: Colors.white,
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           ExhibitionCard(screenWidth: screenWidth, screenHeight: screenHeight),
//           SizedBox(height: screenHeight * 0.05),
//           CustomButton(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Instruction()),
//               );
//             },
//           ),
//           SizedBox(height: screenHeight * 0.05),
//         ],
//       ),
//     );
//   }
// }

// class ExhibitionCard extends StatelessWidget {
//   final double screenWidth;
//   final double screenHeight;

//   const ExhibitionCard({required this.screenWidth, required this.screenHeight});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Positioned(
//           top: screenHeight * 0.004,
//           left: screenWidth * 0,
//           child: Container(
//               margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Centré horizontalement

//             width: screenWidth * 0.82,
//             height: screenHeight * 0.17,
//             decoration: BoxDecoration(
//               color: const Color(0xFFB7D6DD), // Bleu clair
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.only(
//                 bottomRight: Radius.elliptical(25, 25),
//                 topLeft: Radius.elliptical(25, 25),
//                 topRight: Radius.elliptical(4, 4),
//                 bottomLeft: Radius.elliptical(4, 4),
//               ),
//             ),
//           ),
//         ),
//         Container(
//             margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Centré horizontalement

//           width: screenWidth * 0.8,
//           padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
//           decoration: BoxDecoration(
//             color: const Color(0xFF024E50), // Vert foncé
//             shape: BoxShape.rectangle,
//             borderRadius: BorderRadius.only(
//               bottomRight: Radius.elliptical(20, 20),
//               topLeft: Radius.elliptical(20, 20),
//               topRight: Radius.elliptical(4, 4),
//               bottomLeft: Radius.elliptical(4, 4),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Exposition temporaire\nMUCEM',
//                 style: TextStyle(
//                   fontSize: 21.4,
//                   fontFamily: 'Geo',
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.01),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   'Plus de détail',
//                   style: TextStyle(
//                     fontSize: 15.49,
//                     fontFamily: 'Geo',
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFFFFDB3D),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class CustomButton extends StatelessWidget {
//   final VoidCallback onTap;

//   const CustomButton({Key? key, required this.onTap}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Center(
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned(
//             top: 5,
//             left: 5,
//             child: Container(
//               width: screenWidth * 0.7,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFE382), // Jaune/2
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.only(
//                   bottomRight: Radius.elliptical(20, 20),
//                   topLeft: Radius.elliptical(20, 20),
//                   topRight: Radius.elliptical(4, 4),
//                   bottomLeft: Radius.elliptical(4, 4),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: onTap,
//             child: Container(
//               width: screenWidth * 0.7,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFDB3D), // Jaune/1
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.only(
//                   bottomRight: Radius.elliptical(20, 20),
//                   topLeft: Radius.elliptical(20, 20),
//                   topRight: Radius.elliptical(4, 4),
//                   bottomLeft: Radius.elliptical(4, 4),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Text(
//                   'Reprendre la partie',
//                   style: TextStyle(
//                     fontSize: 23,
//                     fontFamily: 'Coolvetica',
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black,
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

// class BottomNavigationBarCustom extends StatelessWidget {
//   final VoidCallback onCalendarPressed;

//   const BottomNavigationBarCustom({Key? key, required this.onCalendarPressed}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       height: 70,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.emoji_events, color: Color(0xFFFFFFFF), size: 42),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Collection()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFFFDB3D), size: 42),
//             onPressed: onCalendarPressed,
//           ),
//           IconButton(
//             icon: const Icon(Icons.map, color: Color(0xFFFFFFFF), size: 42),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MapPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_instruction.dart';
import 'package:chat_app/screens/ParcoursNavigator.dart';
 import 'package:chat_app/screens/map_screen.dart';
  import 'package:chat_app/screens/profile.dart';
   import 'package:chat_app/screens/expo.dart';
 import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Indice de la page active

void _onItemTapped(int index) {
  setState(() {
    if (index == 2) {
      // Change la clé de Collection() pour forcer la reconstruction
      _collectionKey = UniqueKey();
    }
    _selectedIndex = index;
  });
}
void _showGameOptionsPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _codeController = TextEditingController();

      return AlertDialog(
        title: Text("Choisissez une option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le pop-up et affiche le champ pour entrer le code
                _showAccessKeyPopup();
              },
              child: Text("Rejoindre une partie"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Redirige vers la partie sauvegardée
                Navigator.push(context, MaterialPageRoute(builder: (context) => Collection()));
              },
              child: Text("Reprendre ma partie"),
            ),
          ],
        ),
      );
    },
  );
}

void _showAccessKeyPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _accessKeyController = TextEditingController();

      return AlertDialog(
        title: Text("Entrer le code d'accès"),
        content: TextField(
          controller: _accessKeyController,
          decoration: InputDecoration(hintText: "Code d'accès"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              String accessKey = _accessKeyController.text.trim();
              if (accessKey.isNotEmpty) {
                await _joinGame(accessKey);
                Navigator.pop(context);
              }
            },
            child: Text("Valider"),
          ),
        ],
      );
    },
  );
}
Future<void> _joinGame(String accessKey) async {
  try {
    print("📌 Début de la récupération du parcours avec accessKey: $accessKey");

    final QuerySnapshot<Map<String, dynamic>> courseQuery = await FirebaseFirestore.instance
        .collection("courses")
        .where("accessKey", isEqualTo: accessKey)
        .get();

    if (courseQuery.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> courseDoc = courseQuery.docs.first;
      final Map<String, dynamic> courseData = courseDoc.data()!;

      String sectionName = courseData["section"] ?? "section_inconnue";
      String courseId = courseDoc.id;

      print("✅ Section récupérée depuis Firestore : section = $sectionName, courseId = $courseId");

      final QuerySnapshot<Map<String, dynamic>> sectionCourses = await FirebaseFirestore.instance
          .collection("courses")
          .where("section", isEqualTo: sectionName)
          .get();

      if (sectionCourses.docs.isEmpty) {
        print("❌ Aucun cours trouvé pour la section $sectionName !");
        return;
      }

      Map<String, dynamic> courseCollection = {};
      for (var doc in sectionCourses.docs) {
        courseCollection[doc.id] = {
          'url': doc.data()["imageUrl"] ?? "",
          'points': 0,
          'status': false,
          'description': doc.data()["description"] ?? "Description non disponible",
          'createdAt': doc.data()["createdAt"] ?? "",
          'musee': doc.data()["musee"] ?? "",
          'title': doc.data()["title"] ?? "",
          'accessKey': doc.data()["accessKey"] ?? "",
        };
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "collections.$sectionName": courseCollection,
      });

      print("🎉 Partie rejointe avec succès ! Données enregistrées sous collections.$sectionName");
    } else {
      print("❌ Code d'accès invalide !");
    }
  } catch (e) {
    print("🚨 Erreur lors de la récupération du parcours : $e");
  }
}


// Ajoute cette variable dans `_MainScreenState`
Key _collectionKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Affiche la page sélectionnée
        children: [
          Accueil(),       // Page Accueil
          MapPage(),     // Page Carte
           Collection(key: _collectionKey), // Ajoute la clé pour rafraîchir // Page Œuvres
           ProfilApp(),  // Page Profil
           Expo(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF00292A),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Rapproche les icônes
          children: [
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: navBarItem(Icons.home_filled, "Accueil", _selectedIndex == 0),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: navBarItem(Icons.map_outlined, "Carte", _selectedIndex == 1),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: navBarItem(Icons.image_outlined, "Œuvres", _selectedIndex == 2),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(3),
              child: navBarItem(Icons.person_outline, "Profil", _selectedIndex == 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget navBarItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: isSelected ? Colors.white : Colors.white70),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.white70,
            fontFamily: 'Coolvetica',
          ),
        ),
      ],
    );
  }
}


class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {


  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              "BIENVENUE",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Arcane Nine',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Expositions en cours",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Coolvetica',
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1, height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Voir les évents à venir >",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontFamily: 'Coolvetica',
                  ),
                ),
              ),
            ),
            buildExpositionCard("Célébrité - MUCEM", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Expo()),
              );
            }),
            const SizedBox(height: 15),
            buildExpositionCard("Art is Tic - Centrale Med", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Expo()),
              );
            }),
            const SizedBox(height: 30),
            const Text(
              "Mes parties",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Coolvetica',
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1, height: 10),
            buildExpositionCard("Art is Tic - Centrale Med", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Expo()),
              );
            }),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF84ECF0), width: 4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    _showGameOptionsPopup();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Instruction()),
                    // );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Reprendre la partie",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Coolvetica',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
void _showGameOptionsPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _codeController = TextEditingController();

      return AlertDialog(
        title: Text("Choisissez une option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le pop-up et affiche le champ pour entrer le code
                _showAccessKeyPopup();
              },
              child: Text("Rejoindre une partie"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Redirige vers la partie sauvegardée
                Navigator.push(context, MaterialPageRoute(builder: (context) => Collection()));
              },
              child: Text("Reprendre ma partie"),
            ),
          ],
        ),
      );
    },
  );
}

void _showAccessKeyPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _accessKeyController = TextEditingController();

      return AlertDialog(
        title: Text("Entrer le code d'accès"),
        content: TextField(
          controller: _accessKeyController,
          decoration: InputDecoration(hintText: "Code d'accès"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              String accessKey = _accessKeyController.text.trim();
              if (accessKey.isNotEmpty) {
                Map<String, dynamic>? gameData = await _joinGame(accessKey);
                Navigator.pop(context);

                if (gameData != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParcoursNavigator(
                        courseId: gameData["courseId"],
                        userId: gameData["userId"],
                        section: gameData["section"],
                      ),
                    ),
                  );
                } else {
                  // Afficher une alerte en cas de mauvais code
                  _showErrorDialog();
                }
              }
            },
            child: Text("Valider"),
          ),
        ],
      );
    },
  );
}

// Fonction pour afficher un message d'erreur
void _showErrorDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Erreur"),
        content: Text("Le code d'accès est invalide. Vérifiez et réessayez."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

Future<Map<String, dynamic>?> _joinGame(String accessKey) async {
  try {
    print("📌 Début de la récupération du parcours avec accessKey: $accessKey");

    final QuerySnapshot<Map<String, dynamic>> courseQuery = await FirebaseFirestore.instance
        .collection("courses")
        .where("accessKey", isEqualTo: accessKey)
        .get();

    if (courseQuery.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> courseDoc = courseQuery.docs.first;
      final Map<String, dynamic> courseData = courseDoc.data()!;

      String courseId = courseDoc.id;
      String sectionName = courseData["section"] ?? "section_inconnue";  // ✅ Utilisation du vrai nom de la section
      String userId = FirebaseAuth.instance.currentUser!.uid;

      print("📌 Section récupérée : section = $sectionName, courseId = $courseId");

      final QuerySnapshot<Map<String, dynamic>> sectionCourses = await FirebaseFirestore.instance
          .collection("courses")
          .where("section", isEqualTo: sectionName)
          .get();

      if (sectionCourses.docs.isEmpty) {
        print("❌ Aucun cours trouvé pour la section $sectionName !");
        return null;
      }

      Map<String, dynamic> courseCollection = {};
      for (var doc in sectionCourses.docs) {
        courseCollection[doc.id] = {
          'url': doc.data()["imageUrl"] ?? "",
          'points': 0,
          'status': false,
          'description': doc.data()["description"] ?? "Description non disponible",
          'createdAt': doc.data()["createdAt"]?.toDate().toString() ?? "",
          'musee': doc.data()["musee"] ?? "",
          'title': doc.data()["title"] ?? "",
          'accessKey': doc.data()["accessKey"] ?? "",
        };
      }

      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "collections.$sectionName": courseCollection,
      });

      print("🎉 Partie rejointe avec succès ! Données enregistrées sous collections.$sectionName");

      // ✅ Retourner les données pour que `gameData` puisse les utiliser
      return {
        "courseId": courseId,
        "userId": userId,
        "section": sectionName,
      };
    } else {
      print("❌ Code d'accès invalide !");
      return null;
    }
  } catch (e) {
    print("🚨 Erreur lors de la récupération du parcours : $e");
    return null;
  }
}


  // Fonction pour créer une carte d'exposition cliquable
  Widget buildExpositionCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF014E4F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Coolvetica',
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Plus de détail >",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFFE880),
                fontFamily: 'Coolvetica',
              ),
            ),
          ],
        ),
      ),
    );
  }


}
