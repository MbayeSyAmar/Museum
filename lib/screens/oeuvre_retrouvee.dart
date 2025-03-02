// import 'package:flutter/material.dart';

// class Oeuvreretrouvee extends StatelessWidget {
//   const Oeuvreretrouvee({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B2425), // Fond sombre
//       body: const JocondePage(),
//     );
//   }
// }

// class JocondePage extends StatefulWidget {
//   const JocondePage({super.key});

//   @override
//   _JocondePageState createState() => _JocondePageState();
// }

// class _JocondePageState extends State<JocondePage> {
//   bool isFavorite = false;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Bouton Retour
//         Positioned(
//           top: 55,
//           left: 20,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFB7D6DD),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             onPressed: () {},
//             child: const Text(
//               '< Retour',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontFamily: 'Geo',
//               ),
//             ),
//           ),
//         ),

//         // Cadre bleu découpé avec courbature
//         Positioned(
//           top: 165,
//           left: 35,
//           right: 30,
//           child: ClipPath(
//             clipper: SemiCircleClipper(),
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.73,
//               decoration: BoxDecoration(
//                 color: Color(0xFFB7D6DD),
//                 borderRadius: BorderRadius.circular(25),
//               ),
//             ),
//           ),
//         ),

//         // Carte blanche avec courbature
//         Positioned(
//           top: 165,
//           left: 35,
//           right: 35,
//           child: ClipPath(
//             clipper: SemiCircleClipper(),
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.72,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Color(0xFF014E4F),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 50), // Espace pour l'image
//                   const Center(
//                     child: Text(
//                       'Joconde',
//                       style: TextStyle(
//                         // je vais changer la couleur en blanc,
//                         color: Colors.white,
                        
//                         fontSize: 50,
//                         fontFamily: 'Gasoek One',
//                       ),
//                     ),
//                   ),
//                   const Text(
//                     '1503 - 1506',
//                     style: TextStyle(
//                       color: Color(0xFFFFDB3D),
//                       fontSize: 24,
//                       fontFamily: 'Geo',
//                     ),
//                   ),
//                   const Divider(
//                     color: Colors.grey,
//                     thickness: 1,
//                     height: 20,
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text(
//                             'Léonard de Vinci',
//                             style: TextStyle(
//                               color: Color(0xFFFFDB3D),
//                               fontSize: 28,
//                               fontFamily: 'Geo',
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             'Tout voir >',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontFamily: 'Geo',
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             'Huile sur Toile',
//                             style: TextStyle(
//                               color: Color(0xFFFFDB3D),
//                               fontSize: 24,
//                               fontFamily: 'Geo',
//                             ),
//                           ),
//                           Text(
//                             'Impressionnistas',
//                             style: TextStyle(
//                               color: Colors.white,
//                               // color: Color(0xFF39C9D0),
//                               fontSize: 24,
//                               fontFamily: 'Coolvetica',
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             'Peinte au début des années 1500, par De Vinci sur la commande de Francesco del Giocondo, peu de monde avait vraiment...',
//                             style: TextStyle(
//                               color: Colors.white,
//                               // color: Color(0xFF39C9D0),
//                               fontSize: 18,
//                               fontFamily: 'Geo',
//                             ),
//                             textAlign: TextAlign.justify,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Cercle de l'image (agrandi)
//         Positioned(
//           top: 80,
//           left: MediaQuery.of(context).size.width / 2 - 80,
//           child: Container(
//             width: 160,
//             height: 160,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 8),
//               image: const DecorationImage(
//                 image: AssetImage('assets/images/background_hint.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),

//         // Étoile (favoris)
//         Positioned(
//           top: 85,
//           left: MediaQuery.of(context).size.width / 2 + 60,
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 isFavorite = !isFavorite;
//               });
//             },
//             child: Icon(
//               Icons.star,
//               color: isFavorite ? Colors.yellow.shade600 : Colors.white,
//               size: 50,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Clipper pour la courbature
// class SemiCircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     double radius = 80;
//     path.lineTo(size.width / 2 - radius, 0);
//     path.arcToPoint(
//       Offset(size.width / 2 + radius, 0),
//       radius: Radius.circular(radius),
//       clockwise: false,
//     );
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:chat_app/screens/map_screen.dart';
import 'package:chat_app/screens/profile.dart';

class OeuvreRetrouvee extends StatelessWidget {
  final String title;
  final String section;
  final String description;
  final String musee;
  final String createdAt;
  final String imageUrl;
  final String nextAccessKey;

  const OeuvreRetrouvee({
    super.key,
    required this.title,
    required this.section,
    required this.description,
    required this.musee,
    required this.createdAt,
    required this.imageUrl,
    required this.nextAccessKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JocondePage(
        title: title,
        section: section,
        description: description,
        musee: musee,
        createdAt: createdAt,
        imageUrl: imageUrl,
        nextAccessKey: nextAccessKey,
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF00292A),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              ),
              child: navBarItem(Icons.home_filled, "Accueil", false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              ),
              child: navBarItem(Icons.map_outlined, "Carte", false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Collection()),
              ),
              child: navBarItem(Icons.image_outlined, "Œuvres", false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilApp()),
              ),
              child: navBarItem(Icons.person_outline, "Profil", false),
            ),
          ],
        ),
      ),
    );
  }

  Widget navBarItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: isSelected ? Colors.white : Colors.white70),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.white70,
            fontFamily: 'Coolvetica',
          ),
        ),
      ],
    );
  }
}

class JocondePage extends StatefulWidget {
  final String title;
  final String section;
  final String description;
  final String musee;
  final String createdAt;
  final String imageUrl;
  final String nextAccessKey;

  const JocondePage({
    super.key,
    required this.title,
    required this.section,
    required this.description,
    required this.musee,
    required this.createdAt,
    required this.imageUrl,
    required this.nextAccessKey,
  });

  @override
  _JocondePageState createState() => _JocondePageState();
}

class _JocondePageState extends State<JocondePage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 245,
          left: 35,
          right: 35,
          child: ClipPath(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6 - 70,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF014E4F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      widget.title, // 📌 Titre du parcours
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'Arcane Nine',
                      ),
                    ),
                  ),
                  Text(
                    widget.createdAt, // 📅 Date de création
                    style: const TextStyle(
                      color: Color(0xFFFFDB3D),
                      fontSize: 24,
                      fontFamily: 'Geo',
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 20,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.musee, // 🏛️ Musée
                            style: const TextStyle(
                              color: Color(0xFFFFDB3D),
                              fontSize: 28,
                              fontFamily: 'Geo',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tout voir >',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Geo',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'AK2:${widget.nextAccessKey}', // 🔑 Clé d'accès du prochain parcours
                            style: const TextStyle(
                              color: Color(0xFFFFDB3D),
                              fontSize: 24,
                              fontFamily: 'Geo',
                            ),
                          ),
                          Text(
                            widget.section, // 🎨 Section
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Coolvetica',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.description, // 📝 Description du parcours
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Geo',
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 50,
          right: 50,
          child: Container(
            width: 200,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl), // 📌 Image du parcours
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 200 + MediaQuery.of(context).size.height * 0.6 - 20,
          left: 35,
          right: 35,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Color(0xFFB7D6DD), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(0, 60),
              ),
              child: const Text(
                'Retour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 45,
          left: MediaQuery.of(context).size.width / 2 + 80,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            child: SvgPicture.asset(
              'assets/images/star.svg',
              width: 60,
              height: 60,
              colorFilter: ColorFilter.mode(
                isFavorite ? Colors.yellow : Colors.white,
                BlendMode.srcATop,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
