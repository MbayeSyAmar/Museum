import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:chat_app/screens/music_manager.dart';
import 'package:chat_app/screens/page_instruction_question.dart';

class InstructionQuizz extends StatefulWidget {
  const InstructionQuizz({super.key});

  @override
  _InstructionQuizzState createState() => _InstructionQuizzState();
}

class _InstructionQuizzState extends State<InstructionQuizz>
    with SingleTickerProviderStateMixin {
  int selectedAnswerIndex = -1; // Store selected answer index
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
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
    // Dispose du contrôleur d'animation pour libérer les ressources
    _controller.dispose();
    super.dispose();
  }

  Future<void> onAnswerSelected(int index) async {
    setState(() {
      selectedAnswerIndex = index;
    });

    if (index == 1) {
      // Réponse correcte
      setState(() {
        isCorrectAnswer = true;
      });

      await MusicManager.correctMusic(); // Joue la musique de bonne réponse
      await MusicManager.setVolume(1); // Diminue le volume à 50%
      _controller.forward(); // Lancer l'animation
      
      await Future.delayed(const Duration(seconds: 2));

      await MusicManager.stopMusic();
      await MusicManager.setVolume(0.1); // Diminue le volume à 50%
      await MusicManager.playMusic();

      
      // await Future.delayed(const Duration(seconds: 1)); // Attendre la fin de l'animation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const InstructionQuestion(),
        ),
      );
    } else {
      // Réponse incorrecte
      await MusicManager.errorMusic(); // Joue la musique de mauvaise réponse
   
await MusicManager.setVolume(1); // Diminue le volume à 50%
      HapticFeedback.vibrate();
      
      await Future.delayed(const Duration(seconds: 2));

      await MusicManager.stopMusic();
      await MusicManager.setVolume(0.1); // Diminue le volume à 50%
      await MusicManager.playMusic();

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        selectedAnswerIndex = -1; // Réinitialiser la sélection
        isCorrectAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Empêcher l'accès à _controller si non initialisé
    if (!mounted || _controller == null) {
      return const SizedBox(); // Retourner un widget vide si _controller n'est pas prêt
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B2425), // Fond sombre
      body: Stack(
        children: [
          // Cadre jaune avec l'image
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
                  'assets/images/background_hint.png', // Remplace par ton image
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

          // Texte Gérart
          Positioned(
            bottom: 145,
            left: 20,
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
                  fontSize: 24,
                  fontFamily: 'Arcane Nine',
                ),
              ),
            ),
          ),

          // Conteneur bleu flottant derrière le quiz
          Stack(
            children: [
              Positioned(
                bottom: 12,
                left: 30,
                right: 20,
                child: Container(
                  height: 100,
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

              // Conteneur blanc pour le quiz
              Positioned(
                bottom: 15,
                left: 25,
                right: 20,
                child: Container(
                  height: 120,
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Quel est le nom de cette œuvre ?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(3, (index) {
                            return GestureDetector(
                              onTap: () => onAnswerSelected(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedAnswerIndex == index && index != 1
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Réponse ${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Animation de l'icône "vrai"
          if (isCorrectAnswer)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.check_circle,
                  size: 200,
                  color: Colors.greenAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
