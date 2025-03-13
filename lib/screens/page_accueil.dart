
import 'package:flutter/material.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_instruction.dart';
import 'package:chat_app/screens/ParcoursNavigator.dart';
 import 'package:chat_app/screens/map_screen.dart';
  import 'package:chat_app/screens/profile.dart';
   import 'package:chat_app/screens/expo.dart';
 import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'oeuvre_retrouvee.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/screens/countdown_screen.dart';
import 'package:chat_app/screens/music_manager.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Indice de la page active

  @override
  void initState() {
    super.initState();
    MusicManager.stopMusic(); //  Arrête la musique dès l'ouverture de MainScreen
  }
void _onItemTapped(int index) {
  setState(() {
    MusicManager.stopMusic(); 
    if (index == 2) {
      // Change la clé de Collection() pour forcer la reconstruction
      _collectionKey = UniqueKey();
    }
    _selectedIndex = index;
  });
}
// void _showGameOptionsPopup() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("Choisissez une option"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showAccessKeyPopup(); //  Ouvre le pop-up pour entrer un code
//               },
//               child: Text("Rejoindre une partie"),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _resumeLastCourse(); //  Reprendre la dernière partie
//               },
//               child: Text("Reprendre ma partie"),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }


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



Future<Map<String, dynamic>?> _joinGame(String accessKey) async {
  try {
    print(" Début de la récupération du parcours avec accessKey: $accessKey");

    final QuerySnapshot<Map<String, dynamic>> courseQuery = await FirebaseFirestore.instance
        .collection("courses")
        .where("accessKey", isEqualTo: accessKey)
        .get();

    if (courseQuery.docs.isEmpty) {
      print(" Code d'accès invalide !");
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> courseDoc = courseQuery.docs.first;
    final Map<String, dynamic> courseData = courseDoc.data()!;

    String sectionName = courseData["section"] ?? "section_inconnue";
    String courseId = courseDoc.id;

    print(" Section récupérée depuis Firestore : section = $sectionName, courseId = $courseId");

    // Récupérer **tous** les parcours de la même section
    final QuerySnapshot<Map<String, dynamic>> sectionCourses = await FirebaseFirestore.instance
        .collection("courses")
        .where("section", isEqualTo: sectionName)
        .get();

    if (sectionCourses.docs.isEmpty) {
      print(" Aucun cours trouvé pour la section $sectionName !");
      return null;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    //  Vérifier si l'utilisateur a déjà progressé dans ce parcours
    final userDoc = await userRef.get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      print(" Erreur : Impossible de récupérer les données utilisateur !");
      return null;
    }

    Map<String, dynamic>? collections = userData["collections"] as Map<String, dynamic>?;

    if (collections == null) {
      print(" Aucun parcours trouvé pour cet utilisateur.");
      return null;
    }

    int currentStep = 0;
    if (collections.containsKey(sectionName) && collections[sectionName].containsKey(courseId)) {
      currentStep = collections[sectionName][courseId]["currentStep"] ?? 0;
    }

    print(" Progression actuelle récupérée: currentStep = $currentStep");

    //  Enregistrer tous les parcours de la même section
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
        'currentStep': collections.containsKey(sectionName) &&
                collections[sectionName].containsKey(doc.id)
            ? collections[sectionName][doc.id]["currentStep"] ?? 0
            : 0, //  Récupère `currentStep` s'il existe
      };
    }

    await userRef.update({
      "collections.$sectionName": courseCollection,
    });

    print(" Partie rejointe avec succès ! Données enregistrées sous collections.$sectionName");

    return {
      "courseId": courseId,
      "userId": userId,
      "section": sectionName,
      "currentStep": currentStep, //  On envoie la progression
    };
  } catch (e) {
    print(" Erreur lors de la récupération du parcours : $e");
    return null;
  }
}



// Ajoute cette variable dans `_MainScreenState`
Key _collectionKey = UniqueKey();

  @override
@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      return await _showExitAppDialog(context);
    },
    child: Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Affiche la page sélectionnée
        children: [
          Accueil(),       // Page Accueil
          MapPage(),     // Page Carte
          Collection(key: _collectionKey), // Rafraîchir la page Œuvres
          ProfilApp(),  // Page Profil
          Expo(),       // Page Exposition
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF00292A),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    ),
  );
}

Future<bool> _showExitAppDialog(BuildContext context) async {
  return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Quitter l'application ?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Voulez-vous vraiment fermer l'application ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text("Annuler", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00292A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text("Oui", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
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
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                  const SizedBox(height: 2),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                       onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Expo()),
              );
            },
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getRecentCourses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return Center(child: Text("Aucune exposition disponible"));
                      }

                      List<Map<String, dynamic>> courses = snapshot.data!;

                      return Column(
                        children: courses.map((course) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: buildExpositionCard(
                                course["title"],
                                course["episode"],
                                () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ParcoursNavigator(
                                        courseId: course["courseId"],
                                        userId: FirebaseAuth.instance.currentUser!.uid,
                                        section: course["section"],
                                        startIndex: course["currentStep"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),

        //  Section fixe pour les boutons en bas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF00292A),
          ),
          child: Column(
            children: [
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
                      _showAccessKeyPopup();
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
                          "Ajouter un parcours",
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
              // const SizedBox(height: 8),
              // Center(
              //   child: Container(
              //     width: MediaQuery.of(context).size.width * 0.8,
              //     height: 60,
              //     decoration: BoxDecoration(
              //       border: Border.all(color: const Color(0xFF84ECF0), width: 4),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: TextButton(
              //       onPressed: () {
              //         _resumeLastCourse();
              //       },
              //       style: TextButton.styleFrom(
              //         foregroundColor: Colors.white,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       ),
              //       child: const Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             "Reprendre la partie",
              //             style: TextStyle(
              //               fontSize: 22,
              //               fontFamily: 'Coolvetica',
              //               color: Colors.white,
              //             ),
              //           ),
              //           SizedBox(width: 10),
              //           Icon(Icons.play_arrow, color: Colors.white, size: 28),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
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
                Navigator.pop(context);
                _resumeLastCourse(); //  Reprendre la dernière partie
              },
              child: Text("Reprendre ma partie"),
            ),
          ],
        ),
      );
    },
  );
}
void _resumeLastCourse() async {
  print(" _resumeLastCourse() appelé...");

  String userId = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    print(" Aucun utilisateur trouvé !");
    _showErroreDialog("Aucune partie en cours");
    return;
  }

  //  **Récupérer la liste des parcours rejoints avec une clé d'accès**
  List<dynamic> joinedCourses = userDoc.data()?["joinedCourses"] ?? [];

  if (joinedCourses.isEmpty) {
    print(" Aucun parcours rejoint !");
    _showErroreDialog("Aucune partie en cours");
    return;
  }

  //  **Prendre le dernier parcours ajouté dans `joinedCourses`**
  String lastCourseId = joinedCourses.last; //  Prend le dernier élément
  print(" Dernier parcours rejoint : $lastCourseId");

  //  **Récupérer les détails du parcours depuis Firestore**
  final courseDoc = await FirebaseFirestore.instance.collection("courses").doc(lastCourseId).get();

  if (!courseDoc.exists) {
    print(" Le parcours $lastCourseId n'existe pas !");
    _showErroreDialog("Impossible de reprendre la partie !");
    return;
  }

  Map<String, dynamic> courseData = courseDoc.data()!;
  String section = courseData["section"] ?? "Section inconnue";

  //  **Récupérer la progression de l'utilisateur pour ce parcours**
  Map<String, dynamic>? userCollections = userDoc.data()?["collections"];
  int lastStep = 0;
  bool isCompleted = false;

  if (userCollections != null && userCollections.containsKey(section)) {
    Map<String, dynamic>? courseProgress = userCollections[section][lastCourseId];

    if (courseProgress != null) {
      lastStep = courseProgress["currentStep"] ?? 0;
      isCompleted = courseProgress["status"] ?? false;
    }
  }

  print(" Reprise du parcours : ID=$lastCourseId, Section=$section, Étape=$lastStep");

  if (isCompleted) {
    //  Le parcours est terminé → Aller à la page de réussite
    print(" Parcours terminé ! Redirection vers OeuvreRetrouvee...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OeuvreRetrouvee(
          title: courseData["title"] ?? "Titre inconnu",
          section: section,
          description: courseData["description"] ?? "Aucune description",
          musee: courseData["musee"] ?? "Musée inconnu",
          createdAt: courseData["createdAt"]?.toDate().toString() ?? "Date inconnue",
          imageUrl: courseData["imageUrl"] ?? "https://via.placeholder.com/150",
          nextAccessKey: "Aucun parcours suivant",
        ),
      ),
    );
  } else {
    //  Reprendre là où l'utilisateur s'était arrêté
    print("🔄 Reprise du parcours en cours...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ParcoursNavigator(
          courseId: lastCourseId,
          userId: userId,
          section: section,
          startIndex: lastStep, //  Reprend à l'étape où il était
        ),
      ),
    );
  }
}



void _showErroreDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Erreur"),
        content: Text(message),
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
void _showAccessKeyPopup() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      TextEditingController _accessKeyController = TextEditingController();

      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Entrer le code d'accès",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _accessKeyController,
                decoration: InputDecoration(
                  hintText: "Code d'accès",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.blueGrey),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text("Annuler", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
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
                                startIndex: gameData["currentStep"],
                              ),
                            ),
                          );
                        } else {
                          _showErrorDialog();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00292A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text("Valider", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
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

Future<List<Map<String, dynamic>>> _getLastJoinedCourses() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      return [];
    }

    Map<String, dynamic>? collections = userDoc.data()?["collections"];
    if (collections == null || collections.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> allCourses = [];

    collections.forEach((section, courses) {
      if (courses is Map<String, dynamic>) {
        courses.forEach((courseId, courseData) {
          if (courseData is Map<String, dynamic>) {
            allCourses.add({
              "courseId": courseId,
              "title": courseData["title"] ?? "Titre inconnu",
              "imageUrl": courseData["url"] ?? "https://via.placeholder.com/150",
              "createdAt": courseData["createdAt"] ?? "",
              "section": section,
              "accessKey": courseData["accessKey"] ?? "",
            });
          }
        });
      }
    });

    // Trier les parcours par date de création (si applicable)
    allCourses.sort((a, b) {
      return (b["createdAt"].toString().compareTo(a["createdAt"].toString()));
    });

    // Récupérer uniquement les **2 derniers parcours** + 1 parcours défini manuellement
    List<Map<String, dynamic>> latestCourses = allCourses.take(2).toList();

    //  Ajouter le parcours "spécial" accessible à tout le monde
    // latestCourses.insert(0, {
    //   "courseId": "030",
    //   "title": "Art is Tic - DO_IT",
    //   "imageUrl": "https://via.placeholder.com/150",
    //   "createdAt": "",
    //   "section": "Art Is TIC",
    //   "accessKey": "S037GMFM", //  Clé d'accès définie
    // });

    return latestCourses;
  } catch (e) {
    print(" Erreur lors de la récupération des parcours : $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> _getRecentCourses() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      print(" Aucun utilisateur trouvé !");
      return [];
    }

    List<dynamic> joinedCourses = userDoc.data()?["joinedCourses"] ?? [];

    if (joinedCourses.isEmpty) {
      print(" Aucun parcours rejoint !");
      return [];
    }

    // Prendre les **2 derniers parcours rejoints**
    List<String> recentCourseIds = joinedCourses.reversed.take(3).cast<String>().toList();

    List<Map<String, dynamic>> recentCourses = [];

    for (String courseId in recentCourseIds) {
      final courseDoc = await FirebaseFirestore.instance.collection("courses").doc(courseId).get();

      if (courseDoc.exists) {
        String section = courseDoc["section"] ?? "section_inconnue";

        Map<String, dynamic>? collections = userDoc.data()?["collections"];
        int currentStep = 0;

        if (collections != null &&
            collections.containsKey(section) &&
            collections[section].containsKey(courseId)) {
          currentStep = (collections[section][courseId]["currentStep"] as int?) ?? 0; //  Correction ici
        }

        recentCourses.add({
          "title": courseDoc["title"] ?? "Titre inconnu",
          "courseId": courseId,
          "section": section,
          "episode": recentCourses.length + 1,
          "currentStep": currentStep, //  Ne peut plus être null
        });
      }
    }

    print(" Parcours récents récupérés : $recentCourses");
    return recentCourses;
  } catch (e) {
    print(" Erreur lors de la récupération des parcours : $e");
    return [];
  }
}

Future<void> _ensureUniversalCourseLast() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    List<dynamic> joinedCourses = List.from(userDoc.data()?["joinedCourses"] ?? []);

    //  Vérifier si 030 est dans la liste
    if (joinedCourses.contains("030")) {
      joinedCourses.remove("030"); // Supprimer sa position actuelle
      joinedCourses.add("030"); // Remettre à la fin

      //  Mise à jour Firestore avec le nouvel ordre
      await userRef.update({"joinedCourses": joinedCourses});
      print(" Mise à jour : 030 est maintenant en dernière position.");
    }
  } catch (e) {
    print("⚠ Erreur lors de la mise à jour de joinedCourses : $e");
  }
}


Future<Map<String, dynamic>?> _joinGame(String accessKey) async {
  try {
    print("🔍 Début de la récupération du parcours avec accessKey: $accessKey");

    final QuerySnapshot<Map<String, dynamic>> courseQuery = await FirebaseFirestore.instance
        .collection("courses")
        .where("accessKey", isEqualTo: accessKey)
        .get();

    if (courseQuery.docs.isEmpty) {
      print(" Code d'accès invalide !");
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> courseDoc = courseQuery.docs.first;
    final Map<String, dynamic> courseData = courseDoc.data()!;
    String courseId = courseDoc.id;
    String sectionName = courseData["section"] ?? "section_inconnue";

    print(" Section récupérée : section = $sectionName, courseId = $courseId");

    //  Vérifier si l'utilisateur existe dans Firestore
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      print(" L'utilisateur n'existe pas dans Firestore !");
      return null;
    }

    //  Correction ici : Cast explicite
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      print(" Erreur : Impossible de récupérer les données utilisateur !");
      return null;
    }

    List<dynamic> joinedCourses = List.from(userData["joinedCourses"] ?? []);

    print(" joinedCourses AVANT mise à jour : $joinedCourses");

    //  Supprimer "030" temporairement s'il est présent
    joinedCourses.remove("030");

    // 🔹 Ajouter `courseId` s'il n'est pas déjà dans la liste
    if (!joinedCourses.contains(courseId)) {
      joinedCourses.add(courseId);
    }

    //  Ajouter "030" en dernier
    joinedCourses.add("030");

    print(" joinedCourses APRÈS réorganisation : $joinedCourses");

    //  Mise à jour Firestore avec l'ordre forcé
    await userRef.update({
      "joinedCourses": joinedCourses, // 🔹 Mettre à jour avec le bon ordre
    });

    print(" Firestore mis à jour avec joinedCourses (030 en dernier) !");

    //  Mise à jour de `collections`
    Map<String, dynamic> updatedCollections = Map<String, dynamic>.from(userData["collections"] ?? {});
    updatedCollections[sectionName] ??= {}; // Assure que la section existe
    updatedCollections[sectionName][courseId] = {
      'url': courseData["imageUrl"] ?? "",
      'points': 0,
      'status': false,
      'description': courseData["description"] ?? "Description non disponible",
      'createdAt': courseData["createdAt"] ?? "",
      'musee': courseData["musee"] ?? "",
      'title': courseData["title"] ?? "",
      'accessKey': courseData["accessKey"] ?? "",
      'currentStep': 0, // 🔹 Nouveau parcours commence à 0
    };

    //  Mise à jour Firestore avec `collections`
    await userRef.update({
      "collections": updatedCollections,
    });

    print(" Firestore mis à jour avec collections.$sectionName.$courseId !");

    return {
      "courseId": courseId,
      "userId": userId,
      "section": sectionName,
      "currentStep": 0, //  On commence toujours à 0
    };
  } catch (e) {
    print(" Erreur lors de la récupération du parcours : $e");
    return null;
  }
}


  // Fonction pour créer une carte d'exposition cliquable
Widget buildExpositionCard(String title, int episodeNumber, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 285,
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
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'Coolvetica',
            ),
          ),
          const SizedBox(height: 1),
          Text(
            "Épisode $episodeNumber >", //  Affiche "Épisode 1", "Épisode 2"...
            style: const TextStyle(
              fontSize: 20,
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
