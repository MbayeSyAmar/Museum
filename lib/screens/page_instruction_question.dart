import 'package:flutter/material.dart'; 
import 'package:chat_app/screens/oeuvre_retrouvee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
      // Correct answer logic
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

              // Navigate to the Oeuvreretrouvee screen
              await Future.delayed(const Duration(seconds: 2)); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Oeuvreretrouvee(),
                ),
              );
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("'001' data not found!")),
                );
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("'Impressionnistes' map not found!")),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User document not found!")),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      }
    } else {
      setState(() {
        _borderColor = Colors.red;
        _hintText = 'Réponse incorrecte !';
        _hintColor = Colors.red;
      });

      _vibrationController.forward().then((_) => _vibrationController.reverse());

      Timer(const Duration(seconds: 3), () {
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
  // Icône de sortie en haut à gauche
          Positioned(
            top: 35,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // Logique pour quitter
              },
              child: const Icon(
                Icons.directions_run,
                color: Colors.white,
                size: 36,
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
                  end: Offset.zero,          // Arrive à sa position finale
                ).animate(CurvedAnimation(
                  parent: _plus10Controller,
                  curve: Curves.easeOut,     // Animation fluide vers le haut
                )),
                child: FadeTransition(
                  opacity: _plus10FadeAnimation, // Animation de fondu
                  child: const Icon(
                    Icons.celebration,          // Icône d'applaudissements
                    color: Colors.greenAccent,  // Couleur vivante
                    size: 200,                   // Taille ajustée
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
