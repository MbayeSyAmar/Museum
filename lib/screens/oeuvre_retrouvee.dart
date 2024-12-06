import 'package:flutter/material.dart';


class Oeuvreretrouvee extends StatelessWidget {
  const Oeuvreretrouvee({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B2425),
      ),
      home: const JocondePage(),
    );
  }
}

class JocondePage extends StatefulWidget {
  const JocondePage({super.key});

  @override
  _JocondePageState createState() => _JocondePageState();
}

class _JocondePageState extends State<JocondePage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bouton Retour
          Positioned(
            top: 55,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39C9D0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {},
              child: const Text(
                '< Retour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Geo',
                ),
              ),
            ),
          ),

          // Cadre bleu découpé avec courbature
          Positioned(
            top: 165,
            left: 35,
            right: 30,
            child: ClipPath(
              clipper: SemiCircleClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.73,
                decoration: BoxDecoration(
                  color: const Color(0xFF39C9D0),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          // Carte blanche avec courbature
          Positioned(
            top: 165,
            left: 35,
            right: 35,
            child: ClipPath(
              clipper: SemiCircleClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.72,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 100), // Espace pour l'image
                    const Center(
                      child: Text(
                        'Joconde',
                        style: TextStyle(
                          color: Color(0xFF39C9D0),
                          fontSize: 50,
                          fontFamily: 'Gasoek One',
                        ),
                      ),
                    ),
                    const Text(
                      '1503 - 1506',
                      style: TextStyle(
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
                          children: const [
                            Text(
                              'Léonard de Vinci',
                              style: TextStyle(
                                color: Color(0xFFFFDB3D),
                                fontSize: 28,
                                fontFamily: 'Geo',
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tout voir >',
                              style: TextStyle(
                                color: Color(0xFF39C9D0),
                                fontSize: 20,
                                fontFamily: 'Geo',
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Huile sur Toile',
                              style: TextStyle(
                                color: Color(0xFFFFDB3D),
                                fontSize: 24,
                                fontFamily: 'Geo',
                              ),
                            ),
                            Text(
                              'Impressionnistas',
                              style: TextStyle(
                                color: Color(0xFF39C9D0),
                                fontSize: 24,
                                fontFamily: 'Coolvetica',
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Peinte au début des années 1500, par De Vinci sur la commande de Francesco del Giocondo, peu de monde avait vraiment...',
                              style: TextStyle(
                                color: Color(0xFF39C9D0),
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

          // Cercle de l'image (agrandi)
          Positioned(
            top: 80,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/background_hint.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Étoile (favoris)
          Positioned(
            top: 85,
            left: MediaQuery.of(context).size.width / 2 + 60,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
              child: Icon(
                Icons.star,
                color: isFavorite ? Colors.yellow.shade600 : Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper pour la courbature
class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 80;
    path.lineTo(size.width / 2 - radius, 0);
    path.arcToPoint(
      Offset(size.width / 2 + radius, 0),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
