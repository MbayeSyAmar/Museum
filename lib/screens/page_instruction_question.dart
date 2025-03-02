import 'package:flutter/material.dart';
import 'package:chat_app/screens/oeuvre_retrouvee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/music_manager.dart';
import 'dart:async';
import 'package:flutter/services.dart';

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

  Color _borderColor = Colors.white;
  late String _hintText;
  Color _hintColor = Colors.blue;
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
  print("📌 Début de _loadCourseInfo()...");

  try {
    courseId = widget.question["courseId"] ?? "courseId_non_trouvé";
print("📌 Vérification dans _loadCourseInfo() - courseId : $courseId");

    if (courseId == null) {
      print("❌ ERREUR : `courseId` est introuvable dans la question !");
      return;
    }

    print("📌 Recherche du document courses/$courseId dans Firestore...");
    final courseDoc = await FirebaseFirestore.instance.collection("courses").doc(courseId).get();

    if (courseDoc.exists) {
      final courseData = courseDoc.data();
      sectionName = courseData?["section"];

      print("✅ Données du parcours récupérées : courseId = $courseId, section = $sectionName");
    } else {
      print("❌ ERREUR : Aucun document trouvé pour courseId = $courseId");
    }
  } catch (e) {
    print("❌ ERREUR lors de la récupération des infos du parcours : $e");
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
        print("❌ L'utilisateur n'existe pas dans Firestore !");
        return;
      }

      if (sectionName == null || courseId == null) {
        print("❌ ERREUR : `sectionName` ou `courseId` est toujours null !");
        return;
      }

      final collectionsData = userDoc.data()?['collections'];

      print("📌 Données utilisées pour la mise à jour : section = $sectionName, courseId = $courseId");

      if (collectionsData != null && collectionsData.containsKey(sectionName)) {
        final sectionData = collectionsData[sectionName];

        if (sectionData != null && sectionData.containsKey(courseId)) {
          print("✅ Mise à jour des points du parcours...");

          await userRef.update({
            "collections.$sectionName.$courseId.points": FieldValue.increment(1),
            "collections.$sectionName.$courseId.status": true,
          });

          print("✅ Réponse correcte ! Passage à l'étape suivante...");

          if (mounted) {
            print("📌 Navigation en cours... fermeture de l'écran actuel.");
            Navigator.pop(context); // 🔥 Fermer l'écran avant d'appeler onNext()
          }

          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              print("📌 widget.onNext() est exécuté !");
              widget.onNext();
            } else {
              print("❌ ERREUR: widget.onNext() ne peut pas être exécuté car le widget n'est plus monté !");
            }
          });
        } else {
          print("❌ Aucune donnée trouvée pour le cours actuel ($courseId) dans la section ($sectionName).");
        }
      } else {
        print("❌ Section $sectionName non trouvée dans les collections.");
      }
    } catch (e) {
      print("❌ Erreur lors de la mise à jour de l'utilisateur : $e");
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B2425),
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            bottom: 150,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
              ),
              child: ClipRect(
                child: widget.question["imageUrl"] != null
                    ? Image.network(
                        widget.question["imageUrl"],
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/background_hint.png', fit: BoxFit.cover),
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
                color: const Color(0xFF39C9D0),
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
                  color: Colors.white,
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
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                  cursorColor: Colors.blue,
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
            right: 20,
            child: GestureDetector(
              onTap: _handleSubmit,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
