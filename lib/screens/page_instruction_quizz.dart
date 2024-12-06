import 'package:flutter/material.dart';
import 'package:chat_app/screens/page_instruction_question.dart';

class InstructionQuizz extends StatefulWidget {
  const InstructionQuizz({super.key});

  @override
  _InstructionQuizzState createState() => _InstructionQuizzState();
}

class _InstructionQuizzState extends State<InstructionQuizz> {
  bool showQuiz = true; // Affiche le quiz

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B2425),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            // Cadre jaune avec l'image
            Positioned(
              top: 70,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  bottom: 12, // Position ajustée
                  left: 30, // Aligne avec le style précédent
                  right: 20, // Assure un cadre propre
                  child: Container(
                    // width: double.infinity,
                    height: 100, // Légèrement plus haut que le conteneur blanc
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

                // Conteneur blanc pour le quiz
                Positioned(
                  bottom: 15, // Décalage pour qu'il repose sur le bleu flottant
                  left: 25,
                  right: 20,
                  child: Container(
                    // width: 60,
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
                          const SizedBox(
                              height:
                                  8), // Espacement entre la question et les réponses
                          Column(
                            children: List.generate(3, (index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InstructionQuestion(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
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
          ],
        ),
      ),
    );
  }
}
