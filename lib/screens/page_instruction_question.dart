import 'package:flutter/material.dart';
import 'package:chat_app/screens/oeuvre_retrouvee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstructionQuestion extends StatefulWidget {
  const InstructionQuestion({super.key});

  @override
  _InstructionQuestionState createState() => _InstructionQuestionState();
}

class _InstructionQuestionState extends State<InstructionQuestion> {
  final TextEditingController _textController = TextEditingController();

  // Firestore and FirebaseAuth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle the submission of text
Future<void> _handleSubmit() async {
  final currentUser = FirebaseAuth.instance.currentUser; // Get the current user
  if (currentUser == null) {
    // If no user is logged in, exit the function
    return;
  }

  final userId = currentUser.uid; // User ID to identify the current user
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  final answer = _textController.text.trim().toLowerCase();

  if (answer == "babacar") {
    // Correct answer logic
    try {
      // Fetch the current user data
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        // Access the 'Impressionnistes' field in the 'collections' map
        final impressionnistesData = userDoc.data()?['collections']?['Impressionnistes'];

        if (impressionnistesData != null) {
          // Get the '001' map inside 'Impressionnistes'
          final impressionnistes001 = impressionnistesData['001'];

          if (impressionnistes001 != null) {
            final currentPoints = impressionnistes001['points'] ?? 0;
            final currentStatus = impressionnistes001['status'] ?? false;

            // Update the '001' map inside 'Impressionnistes'
            await userRef.update({
              'collections.Impressionnistes.001.points': 2,  // Increment points
              'collections.Impressionnistes.001.status': true,  // Set status to true
              // 'collections.Impressionnistes.001.url': 'https://your-new-url.com', // New URL example
              // 'collections.Impressionnistes.001.description': 'Updated description', // Updated description example
            });

            // Navigate to the Oeuvreretrouvee screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Oeuvreretrouvee(),
              ),
            );
          } else {
            // If '001' doesn't exist in the data
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("'001' data not found!")),
              );
            }
          }
        } else {
          // Handle case where 'Impressionnistes' map doesn't exist
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("'Impressionnistes' map not found!")),
            );
          }
        }
      } else {
        // Handle case where user document doesn't exist
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User document not found!")),
          );
        }
      }
    } catch (e) {
      // Show error if something goes wrong
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  } else {
    // If the answer is wrong, show a message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect answer. Try again!")),
      );
    }
  }
}





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
                    'assets/images/background_hint.png', // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Blue background for the floating text input
            Positioned(
              bottom: 12, // Position adjusted
              left: 30, // Align with previous style
              right: 20, // Ensure clean frame
              child: Container(
                height: 100, // Slightly taller for the design
                decoration: BoxDecoration(
                  color: const Color(0xFF39C9D0), // Light blue
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
              bottom: 15, // Offset to rest on the floating blue
              left: 25,
              right: 20,
              child: Container(
                height: 120, // Text box height
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
                      3, // Limit lines for a reasonable height
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write here...',
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
                onTap: _handleSubmit, // Call the submit function here
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
