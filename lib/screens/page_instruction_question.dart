import 'package:flutter/material.dart';
import 'package:chat_app/screens/oeuvre_retrouvee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/music_manager.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InstructionQuestion extends StatefulWidget {
  final Map<String, dynamic> question;
  final String userId;
  final VoidCallback onNext;

  InstructionQuestion({required this.question, required this.onNext, required this.userId,});

  @override
  _InstructionQuestionState createState() => _InstructionQuestionState();
}

class _InstructionQuestionState extends State<InstructionQuestion> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _vibrationController;
  late Animation<Offset> _vibrationAnimation;
  late AnimationController _plus10Controller;
  late Animation<double> _plus10FadeAnimation;

  Color _borderColor = const Color(0xFFFFDB3D);
  late String _hintText;
  Color _hintColor = const Color.fromARGB(255, 255, 255, 255);
  bool _showPlus10 = false;
  String? sectionName;
String? courseId;

  @override
  void initState() {
    super.initState();
    _hintText = widget.question["text"] ?? "Question introuvable...";
 // Récupérer les informations du parcours
  _loadCourseInfo();
    _vibrationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _vibrationAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_vibrationController);

    _plus10Controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _plus10FadeAnimation = CurvedAnimation(
      parent: _plus10Controller,
      curve: Curves.easeInOut,
    );
  }

  @override
@override
void dispose() {
  if (mounted) {
    MusicManager.stopMusic();
  }
  _vibrationController.dispose();
  _plus10Controller.dispose();
  _textController.dispose();
  super.dispose();
}

Future<void> _loadCourseInfo() async {
  print(" Début de _loadCourseInfo()...");

  try {
    courseId = widget.question["courseId"] ?? "courseId_non_trouvé";
print(" Vérification dans _loadCourseInfo() - courseId : $courseId");

    if (courseId == null) {
      print(" ERREUR : `courseId` est introuvable dans la question !");
      return;
    }

    print(" Recherche du document courses/$courseId dans Firestore...");
    final courseDoc = await FirebaseFirestore.instance.collection("courses").doc(courseId).get();

    if (courseDoc.exists) {
      final courseData = courseDoc.data();
      sectionName = courseData?["section"];

      print(" Données du parcours récupérées : courseId = $courseId, section = $sectionName");
    } else {
      print(" ERREUR : Aucun document trouvé pour courseId = $courseId");
    }
  } catch (e) {
    print(" ERREUR lors de la récupération des infos du parcours : $e");
  }
}
void _previousStep() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userId = currentUser.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  if (sectionName == null || courseId == null) {
    print(" ERREUR : sectionName ou courseId introuvable !");
    return;
  }

  try {
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      print(" L'utilisateur n'existe pas dans Firestore !");
      return;
    }

    final collectionsData = userDoc.data()?['collections'];
    if (collectionsData != null &&
        collectionsData.containsKey(sectionName) &&
        collectionsData[sectionName].containsKey(courseId)) {
      final int currentStep = collectionsData[sectionName][courseId]["currentStep"] ?? 0;

      if (currentStep > 0) {
        await userRef.update({
          "collections.$sectionName.$courseId.currentStep": FieldValue.increment(-1),
        });

        print("⏪ Retour à l'étape précédente : currentStep = ${currentStep - 1}");

        if (mounted) {
          Navigator.pop(context); // 🔄 Retourner à l'étape précédente
        }
      } else {
        // 🚀 **Si `currentStep == 0`, redirige vers la page d'accueil**
        print("🏠 Retour à la page d'accueil car on est à l'étape 0 !");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false, //  Efface tout l'historique
          );
        }
      }
    } else {
      print(" ERREUR : Données du parcours introuvables !");
    }
  } catch (e) {
    print(" ERREUR lors du retour en arrière : $e");
  }
}


Future<void> _handleSubmit() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userId = currentUser.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  final answer = _textController.text.trim().toLowerCase();
  final correctAnswer = widget.question["correctAnswer"]?.toLowerCase() ?? "";

  if (answer == correctAnswer) {
    await MusicManager.correctMusic();
    await MusicManager.setVolume(1);

    if (!mounted) return;
    setState(() {
      _showPlus10 = true;
    });

    _plus10Controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _showPlus10 = false;
        });
      }
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await MusicManager.stopMusic();
    await MusicManager.setVolume(0.1);
    await MusicManager.playMusic();

    try {
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        print(" L'utilisateur n'existe pas dans Firestore !");
        return;
      }

      final collectionsData = userDoc.data()?['collections'];

      if (collectionsData != null && sectionName != null && courseId != null) {
        final currentCourse = collectionsData[sectionName]?[courseId];

        if (currentCourse != null) {
          print(" Mise à jour des points du parcours...");

          //  **Mise à jour des points (toujours +1)**
          await userRef.update({
            "collections.$sectionName.$courseId.points": FieldValue.increment(1),
            "collections.$sectionName.$courseId.currentStep": FieldValue.increment(1), //  Suivi de la progression
          });

          print(" Réponse correcte ! Vérification si le parcours est terminé...");

          // 🔍 **Vérifier si l'utilisateur a terminé toutes les étapes du parcours**
          final courseRef = FirebaseFirestore.instance.collection("courses").doc(courseId);
          final courseDoc = await courseRef.get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data();
            List<String> order = List<String>.from(courseData?["order"] ?? []);

            int userCurrentStep = (currentCourse["currentStep"] ?? 0) + 1; //  Ajout de +1 car on vient d'avancer

            if (userCurrentStep >= order.length) {
              //  **Fin du parcours ! Mettre `status = true`**
              await userRef.update({
                "collections.$sectionName.$courseId.status": true,
              });

              print("🎉 Parcours terminé ! ");
            } else {
              print("⏩ Parcours en cours... (Étape $userCurrentStep/${order.length})");
            }
          }

          if (!mounted) {
  print("  ERREUR: _handleSubmit() ne peut pas s'exécuter car le widget est démonté.");
  return;
}

print(" ⏭️ Exécution immédiate de widget.onNext()...");
widget.onNext(); //  Exécute avant de fermer l'écran

Future.delayed(Duration(milliseconds: 100000), () {
  if (mounted) {
    print(" 🔄 Fermeture de l'écran et navigation...");
    Navigator.pop(context);
  } else {
    print("  ERREUR: Impossible de fermer l'écran, le widget est déjà démonté.");
  }
});

//  Ajout d'un plan B si la navigation ne s'est pas faite
Future.delayed(Duration(seconds: 100), () {
  if (mounted) {
    print(" 🚨 Navigation forcée car l'écran n'a pas changé !");
    widget.onNext();
  }
});

        } else {
          print(" Aucune donnée trouvée pour le cours actuel ($courseId) dans la section ($sectionName).");
        }
      } else {
        print(" Erreur : données utilisateur incomplètes.");
      }
    } catch (e) {
      print(" Erreur lors de la mise à jour de l'utilisateur : $e");
    }
  } else {
    await MusicManager.errorMusic();
    await MusicManager.setVolume(1);
    HapticFeedback.vibrate();

    if (mounted) {
      setState(() {
        _borderColor = Colors.red;
        _hintText = 'Réponse incorrecte !';
        _hintColor = Colors.red;
      });
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await MusicManager.stopMusic();
    await MusicManager.setVolume(0.1);
    await MusicManager.playMusic();
  }
}


@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      return await _showExitGameDialog(context);
    },
    child: Scaffold(
      backgroundColor: const Color(0xFF0B2425),
      body: Stack(
        children: [
          //  SVG "Run" en haut à gauche (même position que le quiz)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                //  Navigation vers la page d'accueil
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()), //  Remplace `MainScreen()` par ta page d'accueil
                  (Route<dynamic> route) => false,
                );
              },
              child: SvgPicture.asset(
                'assets/images/mdi_run-fast.svg', //  Chemin vers ton fichier SVG
                width: 36, //  Taille ajustable
                height: 36,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFDB3D), BlendMode.srcIn, //  Applique la couleur jaune
                ),
              ),
            ),
          ),
          //  Lampe en haut à droite (même position que le quiz)
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _showHintPopup,
              child: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFDB3D),
                size: 36,
              ),
            ),
          ),
          //  Image ajustée avec son cadre (même taille que le quiz)
          Positioned(
            top: 95,
            left: 20,
            right: 20,
            bottom: 145,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
              ),
              child: ClipRect(
                child: widget.question["imageUrl"] != null
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fill, //  Remplit tout sans couper
                          child: Image.network(widget.question["imageUrl"]),
                        ),
                      )
                    : SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.asset('assets/images/background_hint.png'),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 30,
            right: 20,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB3D),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.elliptical(20, 20),
                  topLeft: Radius.elliptical(20, 20),
                  topRight: Radius.elliptical(4, 4),
                  bottomLeft: Radius.elliptical(4, 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 25,
            right: 20,
            child: SlideTransition(
              position: _vibrationAnimation,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00292A),
                  border: Border.all(color: _borderColor, width: 2),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.elliptical(20, 20),
                    topLeft: Radius.elliptical(20, 20),
                    topRight: Radius.elliptical(4, 4),
                    bottomLeft: Radius.elliptical(4, 4),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Color.fromARGB(255, 249, 250, 250), fontSize: 16),
                  cursorColor: const Color.fromARGB(255, 255, 255, 255),
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _hintText,
                    hintStyle: TextStyle(color: _hintColor),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20, //  Ajout de la flèche de retour à gauche
            child: GestureDetector(
              onTap: _previousStep,
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFFFDB3D),
                size: 36,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: GestureDetector(
              onTap: _handleSubmit,
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFFFFDB3D),
                size: 36,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showHintPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF00292A), //  Fond bleu foncé
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), //  Bords arrondis
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFFFDB3D), size: 28), //  Icône lampe stylée
            const SizedBox(width: 8),
            const Text(
              "Indice 🧐",
              style: TextStyle(
                color: Colors.white, //  Texte blanc
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "💡 La bonne réponse est :\n\n🎯 ${widget.question['correctAnswer']}",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white, //  Texte blanc
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFDB3D), //  Bouton Jaune
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); //  Ferme la pop-up
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF00292A), //  Texte bleu foncé
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  @override
/// 🚀 Fonction pour afficher le pop-up de retour vers l’accueil
Future<bool> _showExitGameDialog(BuildContext context) async {
  return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Fond semi-transparent
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
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
                      Icon(Icons.exit_to_app, size: 50, color: Colors.redAccent),
                      SizedBox(height: 10),
                      Text(
                        "Quitter le parcours ?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Voulez-vous retourner à l'accueil ? Votre progression sera sauvegardée.",
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
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("Annuler", style: TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                
                                Navigator.pop(context, true);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("Oui", style: TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}
}
