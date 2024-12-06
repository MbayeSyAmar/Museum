import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Ajouter le package audioplayers
import 'package:chat_app/screens/page_instruction_quizz.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instance du lecteur audio

  @override
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libérer les ressources audio
    super.dispose();
  }

  void _startTextAnimation() async {
    // Jouer le son en boucle
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/typing.mp3')); // Chemin vers le son d'écriture

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _audioPlayer.stop(); // Arrêter le son une fois l'animation terminée
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
          Stack(
            children: [
              // Floating Blue Background
              Positioned(
                bottom: 30, // Décalage pour qu'il apparaisse derrière le blanc
                left: 25, // Ajuste l'alignement
                right: 55, // Décalage pour maintenir le style
                child: Container(
                  width: double.infinity, // Largeur maximale
                  height: 110, // Légèrement plus grand que le blanc
                  decoration: BoxDecoration(
                    color: const Color(0xFF39C9D0), // Bleu clair
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
              // Main White Container
              Positioned(
                bottom: 32,
                left: 20,
                right: 60,
                child: Container(
                  width: double.infinity,
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
                  padding: const EdgeInsets.all(10),
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
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InstructionQuizz()),
                );
              },
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
                size: 36,
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
