import 'package:chat_app/screens/music_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_instruction.dart';
import 'package:chat_app/screens/map_screen.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  void initState() {
    _stopMusic();
    super.initState();
  }

  Future<void> _stopMusic() async {
    await MusicManager.stopMusic(); // Arrête la musique via MusicManager
  }

  Future<String> _getFirstName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String fullName = userDoc['fullName'] ?? "Utilisateur";
      return fullName.split(" ")[0]; // Retourne le premier prénom
    }
    return "Utilisateur";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2425),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FutureBuilder<String>(
                  future: _getFirstName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Erreur lors du chargement"));
                    } else {
                      return HomeArtGo(firstName: snapshot.data ?? "Utilisateur");
                    }
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBarCustom(
              onCalendarPressed: () {
                // Ajoutez ici l'action pour le bouton Calendrier
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomeArtGo extends StatelessWidget {
  final String firstName;

  const HomeArtGo({required this.firstName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.04),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Niveau 1',
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: 'Coolvetica',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontFamily: 'Coolvetica',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
             CircleAvatar(
  radius: 25,
  backgroundImage: AssetImage("assets/images/background_hint.png"),
),

            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          const Text(
            'Expositions en cours',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Coolvetica',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white,
          ),
          SizedBox(height: screenHeight * 0.01),
          const Text(
            'Voir les évents à venir >',
            style: TextStyle(
              fontSize: 15.49,
              fontFamily: 'Geo',
              fontWeight: FontWeight.w500,
              color: Color(0xFFFDFDFD),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          ExhibitionCard(screenWidth: screenWidth, screenHeight: screenHeight),
          SizedBox(height: screenHeight * 0.03),
          const Text(
            'Mes parties',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Coolvetica',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white,
          ),
          SizedBox(height: screenHeight * 0.01),
          ExhibitionCard(screenWidth: screenWidth, screenHeight: screenHeight),
          SizedBox(height: screenHeight * 0.05),
          CustomButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Instruction()),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }
}

class ExhibitionCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const ExhibitionCard({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: screenHeight * 0.004,
          left: screenWidth * 0,
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Centré horizontalement

            width: screenWidth * 0.82,
            height: screenHeight * 0.17,
            decoration: BoxDecoration(
              color: const Color(0xFFB7D6DD), // Bleu clair
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.elliptical(25, 25),
                topLeft: Radius.elliptical(25, 25),
                topRight: Radius.elliptical(4, 4),
                bottomLeft: Radius.elliptical(4, 4),
              ),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Centré horizontalement

          width: screenWidth * 0.8,
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF024E50), // Vert foncé
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.elliptical(20, 20),
              topLeft: Radius.elliptical(20, 20),
              topRight: Radius.elliptical(4, 4),
              bottomLeft: Radius.elliptical(4, 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exposition temporaire\nMUCEM',
                style: TextStyle(
                  fontSize: 21.4,
                  fontFamily: 'Geo',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Plus de détail',
                  style: TextStyle(
                    fontSize: 15.49,
                    fontFamily: 'Geo',
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFDB3D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;

  const CustomButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: screenWidth * 0.7,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE382), // Jaune/2
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(20, 20),
                  topLeft: Radius.elliptical(20, 20),
                  topRight: Radius.elliptical(4, 4),
                  bottomLeft: Radius.elliptical(4, 4),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: screenWidth * 0.7,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB3D), // Jaune/1
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(20, 20),
                  topLeft: Radius.elliptical(20, 20),
                  topRight: Radius.elliptical(4, 4),
                  bottomLeft: Radius.elliptical(4, 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Reprendre la partie',
                  style: TextStyle(
                    fontSize: 23,
                    fontFamily: 'Coolvetica',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarCustom extends StatelessWidget {
  final VoidCallback onCalendarPressed;

  const BottomNavigationBarCustom({Key? key, required this.onCalendarPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Color(0xFFFFFFFF), size: 42),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Collection()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFFFDB3D), size: 42),
            onPressed: onCalendarPressed,
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Color(0xFFFFFFFF), size: 42),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}


// ------------------------------
//  import 'package:chat_app/screens/music_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_app/screens/page_collection.dart';
// import 'package:chat_app/screens/page_instruction.dart';
// import 'package:chat_app/screens/map_screen.dart';

// class Accueil extends StatefulWidget {
//   const Accueil({super.key});

//   @override
//   State<Accueil> createState() => _AccueilState();
// }

// class _AccueilState extends State<Accueil> {
//    @override
//   void initState() {
//     _stopMusic();
//     super.initState();
//   }

//   Future<void> _stopMusic() async {
//     await MusicManager.stopMusic(); // Arrête la musique via MusicManager
//   }

//   Future<String> _getFirstName() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       String fullName = userDoc['fullName'] ?? "Utilisateur";
//       return fullName.split(" ")[0]; // Retourne le premier prénom
//     }
//     return "Utilisateur";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B2425),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: FutureBuilder<String>(
//                   future: _getFirstName(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return const Center(child: Text("Erreur lors du chargement"));
//                     } else {
//                       return HomeArtGo(firstName: snapshot.data ?? "Utilisateur");
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),
//           const Align(
//             alignment: Alignment.bottomCenter,
//             child: BottomNavigationBarCustom(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HomeArtGo extends StatelessWidget {
//   final String firstName;

//   const HomeArtGo({required this.firstName});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 28),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Niveau 1',
//                     style: TextStyle(
//                       fontSize: 23,
//                       fontFamily: 'Coolvetica',
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     firstName,
//                     style: const TextStyle(
//                       fontSize: 23,
//                       fontFamily: 'Coolvetica',
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               const CircleAvatar(
//                 radius: 25,
//                 backgroundImage: NetworkImage("https://via.placeholder.com/52x52"),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Expositions en cours',
//             style: TextStyle(
//               fontSize: 23,
//               fontFamily: 'Coolvetica',
//               fontWeight: FontWeight.w400,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Container(
//             width: double.infinity,
//             height: 1,
//             color: Colors.white,
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Voir les évents à venir >',
//             style: TextStyle(
//               fontSize: 15.49,
//               fontFamily: 'Geo',
//               fontWeight: FontWeight.w500,
//               color: Color(0xFFFDFDFD),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ExhibitionCard(),
//           const SizedBox(height: 20),
//           const Text(
//             'Mes parties',
//             style: TextStyle(
//               fontSize: 23,
//               fontFamily: 'Coolvetica',
//               fontWeight: FontWeight.w400,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Container(
//             width: double.infinity,
//             height: 1,
//             color: Colors.white,
//           ),
//           const SizedBox(height: 6),
//           ExhibitionCard(),
//           const SizedBox(height: 35),
//           CustomButton(onTap: () => Accueil()),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
// }

// // CustomButton, ExhibitionCard, BottomNavigationBarCustom classes remain unchanged.


// // button
// class CustomButton extends StatelessWidget {
//   final VoidCallback onTap;

//   const CustomButton({Key? key, required this.onTap}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Stack(
//         clipBehavior: Clip.none, // Permet aux éléments de dépasser les limites
//         children: [
//           // Floating yellow background
//           Positioned(
//             top: 5,
//             left: 5,
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFE382), // Jaune/2
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.only(
//                   bottomRight: Radius.elliptical(20, 20),
//                   topLeft: Radius.elliptical(20, 20),
//                   topRight: Radius.elliptical(4, 4),
//                   bottomLeft: Radius.elliptical(4, 4),
//                 ),
//               ),
//             ),
//           ),
//           // Main Button
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Instruction()),
//               );
//             },
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFDB3D), // Jaune/1
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.only(
//                   bottomRight: Radius.elliptical(20, 20),
//                   topLeft: Radius.elliptical(20, 20),
//                   topRight: Radius.elliptical(4, 4),
//                   bottomLeft: Radius.elliptical(4, 4),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Text(
//                   'Reprendre la partie',
//                   style: TextStyle(
//                     fontSize: 23,
//                     fontFamily: 'Coolvetica',
//                     fontWeight: FontWeight.w400,
//                     color: Color.fromARGB(255, 0, 0, 0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ExhibitionCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none, // Permet aux éléments de dépasser les limites
//       children: [
//         // Floating blue background
//         Positioned(
//           top: 8,
//           left: 8,
//           child: Container(
//             margin: const EdgeInsets.symmetric(
//                 horizontal: 20), // Réduit les marges externes
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//             width: MediaQuery.of(context).size.width -
//                 80, // Même largeur que la carte principale
//             height: 120, // Ajustez la hauteur si nécessaire
//             decoration: BoxDecoration(
//               color: const Color(0xFFB7D6DD), // Bleu clair
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.only(
//                 bottomRight: Radius.elliptical(25, 25),
//                 topLeft: Radius.elliptical(25, 25),
//                 topRight: Radius.elliptical(4, 4),
//                 bottomLeft: Radius.elliptical(4, 4),
//               ),
//             ),
//           ),
//         ),
//         // Main Card
//         Container(
//           margin: const EdgeInsets.symmetric(
//               horizontal: 20), // Réduit les marges externes
//           padding: const EdgeInsets.symmetric(
//               horizontal: 10, vertical: 15), // Réduit les marges internes
//           width: MediaQuery.of(context).size.width *
//               0.9, // 90% de la largeur de l'écran
//           decoration: BoxDecoration(
//             color: const Color(0xFF024E50), // Vert foncé
//             shape: BoxShape.rectangle,
//             borderRadius: BorderRadius.only(
//               bottomRight: Radius.elliptical(20, 20),
//               topLeft: Radius.elliptical(20, 20),
//               topRight: Radius.elliptical(4, 4),
//               bottomLeft: Radius.elliptical(4, 4),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Exposition temporaire MUCEM',
//                 style: TextStyle(
//                   fontSize: 21.4,
//                   fontFamily: 'Geo',
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white, // Blanc
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   'Plus de détail',
//                   style: TextStyle(
//                     fontSize: 15.49,
//                     fontFamily: 'Geo',
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFFFFDB3D), // Jaune/1
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BottomNavigationBarCustom extends StatelessWidget {
//   const BottomNavigationBarCustom({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       height: 70,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.emoji_events, color: Color(0xFFFFFFFF), size: 42),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Collection()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFFFDB3D), size: 42),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.map, color: Color(0xFFFFFFFF), size: 42),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MapPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }