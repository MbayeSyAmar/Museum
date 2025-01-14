import 'package:flutter/material.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_instruction.dart';
import 'package:chat_app/screens/map_screen.dart';


class Accueil extends StatelessWidget {
  const Accueil({super.key});

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2425), // Couleur définie pour le fond
      body: Stack(
        children: [
          // Utilisez un SafeArea pour réduire l'espace automatiquement en haut
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20, // Espace en bas pour le BottomNavigationBar
                ),
                child: HomeArtGo(),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBarCustom(),
          ),
        ],
      ),
    );
  }

}

class HomeArtGo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Niveau 1',
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: 'Coolvetica',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Jul13013',
                    style: TextStyle(
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
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/52x52"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sections
          const Text(
            'Expositions en cours',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Coolvetica',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 280, // Longueur de la ligne
            height: 1, // Épaisseur de la ligne
            color: Colors.white, // Couleur de la ligne
          ),
          const SizedBox(height: 5),
          const Text(
            'Voir les évents à venir >',
            style: TextStyle(
              fontSize: 15.49,
              fontFamily: 'Geo',
              fontWeight: FontWeight.w500,
              color: Color(0xFFFDFDFD),
            ),
          ),
          const SizedBox(height: 20),
          // Card 1
          ExhibitionCard(),
          const SizedBox(height: 20),
          const Text(
            'Mes parties',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Coolvetica',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 280, // Longueur de la ligne
            height: 1, // Épaisseur de la ligne
            color: Colors.white, // Couleur de la ligne
          ),
          const SizedBox(height: 6),
          // Card 2
          ExhibitionCard(),
          const SizedBox(height: 35),
          CustomButton(onTap: () => Accueil()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// button
class CustomButton extends StatelessWidget {
  final VoidCallback onTap;

  const CustomButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none, // Permet aux éléments de dépasser les limites
        children: [
          // Floating yellow background
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
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
          // Main Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Instruction()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
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
                    color: Color.fromARGB(255, 0, 0, 0),
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

class ExhibitionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Permet aux éléments de dépasser les limites
      children: [
        // Floating blue background
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 20), // Réduit les marges externes
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            width: MediaQuery.of(context).size.width -
                80, // Même largeur que la carte principale
            height: 120, // Ajustez la hauteur si nécessaire
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
        // Main Card
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 20), // Réduit les marges externes
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 15), // Réduit les marges internes
          width: MediaQuery.of(context).size.width *
              0.9, // 90% de la largeur de l'écran
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
                'Exposition temporaire MUCEM',
                style: TextStyle(
                  fontSize: 21.4,
                  fontFamily: 'Geo',
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // Blanc
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Plus de détail',
                  style: TextStyle(
                    fontSize: 15.49,
                    fontFamily: 'Geo',
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFDB3D), // Jaune/1
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

class BottomNavigationBarCustom extends StatelessWidget {
  const BottomNavigationBarCustom({super.key});

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
            onPressed: () {},
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
