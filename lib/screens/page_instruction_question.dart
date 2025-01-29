import 'package:flutter/material.dart';
import 'package:chat_app/screens/oeuvre_retrouvee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/music_manager.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class InstructionQuestion extends StatefulWidget {
  const InstructionQuestion({super.key});

  @override
  _InstructionQuestionState createState() => _InstructionQuestionState();
}

class _InstructionQuestionState extends State<InstructionQuestion>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  // Firestore and FirebaseAuth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Animation controllers
  late AnimationController _vibrationController;
  late Animation<Offset> _vibrationAnimation;
  late AnimationController _plus10Controller;
  late Animation<double> _plus10FadeAnimation;

  Color _borderColor = Colors.white;
  String _hintText = 'Qui est l auteur de ca ? ...';
  Color _hintColor = Colors.blue;

  bool _showPlus10 = false;

  @override
  void initState() {
    super.initState();

    _vibrationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _vibrationAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_vibrationController);

    // Animation controller for +10 effect
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
  void dispose() {
    MusicManager.stopMusic(); // Arrêter la musique à la sortie
    _vibrationController.dispose();
    _plus10Controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Function to handle the submission of text
  Future<void> _handleSubmit() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final answer = _textController.text.trim().toLowerCase();

    if (answer == "babacar") {
      // Bonne réponse
      await MusicManager.correctMusic(); // Jouer la musique de bonne réponse
      await MusicManager.setVolume(1);
           // Start the +10 animation and show it
              setState(() {
                _showPlus10 = true;
              });

              _plus10Controller.forward().then((_) {
                if (mounted) {
                  setState(() {
                    _showPlus10 = false; // Hide the animation after it finishes
                  });
                }
              });
       // Augmenter le volume pour l'effet
      await Future.delayed(const Duration(seconds: 2)); // Attendre l'effet sonore
      await MusicManager.stopMusic();
      await MusicManager.setVolume(0.1); // Diminue le volume à 50%
      await MusicManager.playMusic();

      try {
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          final impressionnistesData = userDoc.data()?['collections']?['Impressionnistes'];

          if (impressionnistesData != null) {
            final impressionnistes001 = impressionnistesData['001'];

            if (impressionnistes001 != null) {
              await userRef.update({
                'collections.Impressionnistes.001.points': 1,
                'collections.Impressionnistes.001.status': true,
              });

         

              // Navigate to the Oeuvreretrouvee screen
              // await Future.delayed(const Duration(seconds: 2));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Oeuvreretrouvee(),
                ),
              );
            }
          }
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      // Mauvaise réponse
      // HapticFeedback.vibrate();
      await MusicManager.errorMusic(); // Jouer la musique de mauvaise réponse
      await MusicManager.setVolume(1); 
      HapticFeedback.vibrate();
      // Augmenter le volume pour l'effet
        _vibrationController.forward().then((_) => _vibrationController.reverse());
        setState(() {
        _borderColor = Colors.red;
        _hintText = 'Réponse incorrecte !';
        _hintColor = Colors.red;
      });
      await Future.delayed(const Duration(seconds: 2)); // Attendre l'effet sonore
      await MusicManager.stopMusic();
      await MusicManager.setVolume(0.1); // Diminue le volume à 50%
      await MusicManager.playMusic();
      

    

      Timer(const Duration(seconds: 2), () {
        setState(() {
          _borderColor = Colors.white;
          _hintText = 'Qui est l auteur de ca ? ...';
          _hintColor = Colors.blue;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2425),
      body: Stack(
        children: [
          // Background image within the frame
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
                child: Image.asset(
                  'assets/images/background_hint.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Blue background for the floating text input
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
          // White text input field
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
          // Animation de l'icône d'applaudissements
          if (_showPlus10)
            Positioned(
              bottom: 300,
              right: 20,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1), // Part du bas (hors écran)
                  end: Offset.zero, // Arrive à sa position finale
                ).animate(CurvedAnimation(
                  parent: _plus10Controller,
                  curve: Curves.easeOut, // Animation fluide vers le haut
                )),
                child: FadeTransition(
                  opacity: _plus10FadeAnimation, // Animation de fondu
                  child: const Icon(
                    Icons.celebration, // Icône d'applaudissements
                    color: Colors.greenAccent, // Couleur vivante
                    size: 200, // Taille ajustée
                  ),
                ),
              ),
            ),
          // Submit arrow icon
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
