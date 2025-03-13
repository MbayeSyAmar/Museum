import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/parcoursnavigator.dart';

import 'dart:async';

class CountdownScreen extends StatefulWidget {
  final String courseId;
  final String userId;
  final String section;
  final int startIndex;

  const CountdownScreen({
    super.key,
    required this.courseId,
    required this.userId,
    required this.section,
    required this.startIndex,
  });

  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  int countdown = 3;
  double countdownTime = 3.0; // Durée initiale du compte à rebours
  bool firebaseLoaded = false;
  bool countdownFinished = false;
  late Stopwatch _stopwatch;
  Map<String, dynamic>? courseData;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start(); // 🔥 Démarrer le chrono Firebase

    // 🚀 Lancer Firebase immédiatement en arrière-plan
    _loadCourseData();

    // 📌 Lancer le compte à rebours immédiatement
    _startCountdown();
  }

  /// **🔥 Charge Firebase en arrière-plan et mesure le temps**
  Future<void> _loadCourseData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      _stopwatch.stop(); // ⏱️ Arrêt du chrono Firebase
      double firebaseTime = _stopwatch.elapsedMilliseconds / 1000.0;
      print("✅ Firebase chargé en $firebaseTime secondes");

      // 🔢 Ajuster la durée du compte à rebours
      setState(() {
        countdownTime = firebaseTime.clamp(3.0, 8.0); // Min 3s, Max 8s
      });

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          courseData = userData?["collections"]?[widget.section]?[widget.courseId];
          firebaseLoaded = true;
        });

        _checkAndNavigate();
      }
    } catch (e) {
      print("❌ Erreur Firebase : $e");
    }
  }

  /// **⏳ Lancer le compte à rebours**
  void _startCountdown() {
    double stepTime = countdownTime / 3; // Temps par étape ajusté

    Timer.periodic(Duration(milliseconds: (stepTime * 1000).toInt()), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (countdown > 1) {
          countdown--;
        } else {
          countdownFinished = true;
          timer.cancel();
          _checkAndNavigate();
        }
      });
    });
  }

  /// **🚀 Passe à `ParcoursNavigator` si tout est prêt**
  void _checkAndNavigate() {
    if (firebaseLoaded && countdownFinished) {
      _navigateToParcours();
    }
  }

  /// **🚀 Navigation vers le parcours**
  void _navigateToParcours() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ParcoursNavigator(
          courseId: widget.courseId,
          userId: widget.userId,
          section: widget.section,
          startIndex: courseData?["currentStep"] ?? widget.startIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          countdown.toString(),
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
