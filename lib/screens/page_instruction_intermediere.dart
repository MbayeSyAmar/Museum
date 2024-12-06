import 'package:flutter/material.dart';
import 'dart:async';


class Instruction extends StatelessWidget {
  const Instruction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B2425),
      ),
      home: const ArtEscapeHome(),
    );
  }
}

class ArtEscapeHome extends StatefulWidget {
  const ArtEscapeHome({super.key});

  @override
  _ArtEscapeHomeState createState() => _ArtEscapeHomeState();
}

class _ArtEscapeHomeState extends State<ArtEscapeHome> {
  String _displayedText = '';
  final String _fullText =
      'Au secours, je suis bloqué entre ces murs Au secours, je suis teste teste teste teste ';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  void _startTextAnimation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 10,
            right: 10,
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
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // Action pour quitter l'écran
              },
              child: const Icon(
                Icons.directions_run,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          // Bleu flottant derrière la carte blanche
          Positioned(
            bottom: 30,
            left: 25,
            right: 15,
            child: Container(
              height: 110, // Ajustement pour correspondre à la carte blanche
              decoration: BoxDecoration(
                color: const Color(0xFF39C9D0),
                borderRadius: BorderRadius.only(
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
          // Carte blanche avec coins arrondis spécifiques et flèches
          Positioned(
            bottom: 34,
            left: 20,
            right: 20,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(20, 20),
                  topLeft: Radius.elliptical(20, 20),
                  topRight: Radius.elliptical(4, 4),
                  bottomLeft: Radius.elliptical(4, 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flèche gauche
                  GestureDetector(
                    onTap: () {
                      // Action pour reculer
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.lightBlueAccent,
                        size: 36,
                      ),
                    ),
                  ),
                  // Texte animé
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        _displayedText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontFamily: 'Coolvetica',
                        ),
                        softWrap: true,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  // Flèche droite
                  GestureDetector(
                    onTap: () {
                      // Action pour avancer
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.lightBlueAccent,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB3D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Gérart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Arcane Nine',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
