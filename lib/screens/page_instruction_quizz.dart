import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:chat_app/screens/music_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:flutter_svg/flutter_svg.dart';


class InstructionQuizz extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final VoidCallback onNext;

  const InstructionQuizz({super.key, required this.quiz, required this.onNext});

  @override
  _InstructionQuizzState createState() => _InstructionQuizzState();
}

class _InstructionQuizzState extends State<InstructionQuizz>
    with SingleTickerProviderStateMixin {
  int selectedAnswerIndex = -1;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
void _previousQuiz() async {
  if (selectedAnswerIndex != -1) {
    print("🚨 Déjà une réponse sélectionnée, retour désactivé.");
    return;
  }

  if (mounted) {
    setState(() {
      selectedAnswerIndex = -1; // Réinitialise la sélection
      isCorrectAnswer = false;
    });
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userId = currentUser.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  final String? sectionName = widget.quiz['section'];
  final String? courseId = widget.quiz['courseId'];

  if (sectionName == null || courseId == null) {
    print(" ERREUR: Impossible de récupérer section et courseId !");
    return;
  }

  try {
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      print(" L'utilisateur n'existe pas dans Firestore !");
      return;
    }

    final collectionsData = userDoc.data()?['collections'];
    if (collectionsData != null && collectionsData.containsKey(sectionName)) {
      final currentCourse = collectionsData[sectionName]?[courseId];

      if (currentCourse != null) {
        int currentStep = (currentCourse["currentStep"] ?? 0);

        if (currentStep > 0) {
          //  **Diminue l'étape et recharge la page**
          await userRef.update({
            "collections.$sectionName.$courseId.currentStep": FieldValue.increment(-1),
          });

          print("🔙 Retour à l'étape précédente : ${currentStep - 1}");

          if (mounted) {
            Navigator.pop(context);
            Future.delayed(Duration(milliseconds: 300), () {
              widget.onNext();
            });
          }
        } else {
          // 🚀 **Si currentStep == 0, renvoyer à l'accueil**
          print("🏠 Retour à la page d'accueil car on est à l'étape 0 !");
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false, //  Efface tout l'historique
            );
          }
        }
      }
    }
  } catch (e) {
    print(" Erreur lors du retour en arrière : $e");
  }
}

Future<void> _handleQuizSubmit(int index) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userId = currentUser.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

 final bool isCorrect = index == int.tryParse(widget.quiz['correctOption'].toString());


  setState(() {
    selectedAnswerIndex = index;
    isCorrectAnswer = isCorrect;
  });

  if (isCorrect) {
    print(" Réponse correcte ! Lecture de la musique...");
    await MusicManager.correctMusic();
    await MusicManager.setVolume(1);
    _controller.forward();

    await Future.delayed(const Duration(seconds: 2));
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

      //  Récupérer `section` et `courseId`
      final String? sectionName = widget.quiz['section'];
      final String? courseId = widget.quiz['courseId'];

      if (sectionName == null || courseId == null) {
        print(" ERREUR: Impossible de récupérer section et courseId !");
        return;
      }

      print("📌 Mise à jour des points pour Section: $sectionName, Course: $courseId");

      if (collectionsData != null && collectionsData.containsKey(sectionName)) {
        final currentCourse = collectionsData[sectionName]?[courseId];

        if (currentCourse != null) {
          await userRef.update({
            "collections.$sectionName.$courseId.points": FieldValue.increment(1),
            "collections.$sectionName.$courseId.currentStep": FieldValue.increment(1),
          });

          print("🎯 Vérification si le parcours est terminé...");

          final courseRef = FirebaseFirestore.instance.collection("courses").doc(courseId);
          final courseDoc = await courseRef.get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data();
            List<String> order = List<String>.from(courseData?["order"] ?? []);

            int userCurrentStep = (currentCourse["currentStep"] ?? 0) + 1;

            if (userCurrentStep >= order.length) {
              await userRef.update({
                "collections.$sectionName.$courseId.status": true,
              });

              print("🎉 Parcours terminé !");
            } else {
              print("⏩ Parcours en cours... (Étape $userCurrentStep/${order.length})");
            }
          }

          if (mounted) {
            print("🔄 Fermeture de l'écran...");
            Navigator.pop(context);

            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                print(" Passage à l'étape suivante...");
                widget.onNext();
              }
            });
          }
        }
      }
    } catch (e) {
      print(" Erreur lors de la mise à jour de l'utilisateur : $e");
    }
  } else {
    await MusicManager.errorMusic();
    await MusicManager.setVolume(1);
    HapticFeedback.vibrate();

    await Future.delayed(const Duration(seconds: 2));
    await MusicManager.stopMusic();
    await MusicManager.setVolume(0.1);
    await MusicManager.playMusic();

    setState(() {
      selectedAnswerIndex = -1;
      isCorrectAnswer = false;
    });
  }
}



  @override
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
     Positioned(
  top: 40, //  Ajuste la position
  left: 20, //  Aligné à gauche
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
          Positioned(
        top: 40, //  Ajuste la hauteur
        right: 20, //  Aligné à droite
        child: GestureDetector(
          onTap: _showHintPopup, //  Affiche la pop-up
          child: const Icon(
            Icons.lightbulb_outline, //  Icône de la lampe
            color: Color(0xFFFFDB3D), //  Jaune comme une vraie lampe
            size: 36, //  Taille ajustée
          ),
        ),
      ),
          Positioned(
  bottom: 10, //  Ajuste la position
  left: 20, //  Aligné à gauche
  child: GestureDetector(
    onTap: _previousQuiz,
    child: const Icon(
      Icons.arrow_back,
      color: Color(0xFFFFDB3D),
      size: 30, //  Plus gros pour bien voir
    ),
  ),
),
  Positioned(
  top: 95,
  left: 20,
  right: 20,
  bottom: 175,
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
    ),
    child: ClipRect(
      child: widget.quiz['imageUrl'] != null && widget.quiz['imageUrl'].isNotEmpty
          ? SizedBox.expand( //  Forcer l'image à prendre toute la place
              child: FittedBox(
                fit: BoxFit.fill, //  Remplit tout sans couper
                child: Image.network(widget.quiz['imageUrl']),
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
  bottom: 40,
  left: 25,
  right: 20,
  child: Container(
    height: 135, // Hauteur Fixe
    // decoration: BoxDecoration(
    //   color: const Color(0xFF00292A),
    //   borderRadius: BorderRadius.only(
    //     bottomRight: Radius.elliptical(20, 20),
    //     topLeft: Radius.elliptical(20, 20),
    //     topRight: Radius.elliptical(4, 4),
    //     bottomLeft: Radius.elliptical(4, 4),
    //   ),
    // ),
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        Text(
          widget.quiz['text'],
          style: const TextStyle(
            color: Color.fromARGB(255, 253, 253, 253),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded( //  Ajout du scroll
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(widget.quiz['options'].length, (index) {
                return GestureDetector(
                  onTap: () => _handleQuizSubmit(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAnswerIndex == index && index != widget.quiz['correctOption']
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFFFFDB3D),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.quiz['options'][index],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ),
  ),
),

        ],
      ),
    ),
  );
}
void _showHintPopup() {
  int correctIndex = int.tryParse(widget.quiz['correctOption'].toString()) ?? 0; //  Convertir en entier
  int displayedIndex = correctIndex + 1; //  Ajoute 1 pour que ça commence à 1

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF00292A), //  Fond bleu foncé
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), //  Coins arrondis
        ),
        title: const Text(
          "Indice 🧐",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "La bonne réponse est l'option n°$displayedIndex", //  Affichage de l'index +1
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); //  Ferme la pop-up
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFFFFDB3D), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}



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
