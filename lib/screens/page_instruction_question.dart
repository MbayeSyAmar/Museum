import 'package:flutter/material.dart';
import 'package:chat_app/screens/oeuvre_retrouvee.dart';

class InstructionQuestion extends StatefulWidget {
  const InstructionQuestion({super.key});

  @override
  _InstructionQuestionState createState() => _InstructionQuestionState();
}

class _InstructionQuestionState extends State<InstructionQuestion> {
  final TextEditingController _textController = TextEditingController();
  bool showQuiz = false; // Toggle between text input and quiz

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
            // Background image within the frame
            Positioned(
              top: 90, // Descend le cadre jaune
              left: 20,
              right: 20,
              bottom: 150, // Ajuste pour faire place à la zone de texte
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
                ),
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/background_hint.png', // Remplace avec le chemin de ton image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Blue background for the floating text input
            Positioned(
              bottom: 12, // Position ajustée
              left: 30, // Aligne avec le style précédent
              right: 20, // Assure un cadre propre
              child: Container(
                height: 100, // Hauteur légèrement plus grande pour le design
                decoration: BoxDecoration(
                  color: const Color(0xFF39C9D0), // Bleu clair
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
              bottom: 15, // Décalage pour qu'il repose sur le bleu flottant
              left: 25,
              right: 20,
              child: Container(
                height: 120, // Hauteur de la zone de texte
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  maxLines:
                      3, // Limite les lignes pour conserver une hauteur raisonnable
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Écrivez ici...',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),

            // Clickable exit icon
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  // Logic to exit the screen
                },
                child: const Icon(
                  Icons.directions_run,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

            // Submit arrow icon
            Positioned(
              bottom: 50,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Oeuvreretrouvee(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.lightBlueAccent,
                  size: 36,
                ),
              ),
            ),

            // "Gérart" label
            Positioned(
              bottom: 150,
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
          ],
        ),
      ),
    );
  }
}
