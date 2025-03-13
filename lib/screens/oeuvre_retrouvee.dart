
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:chat_app/screens/map_screen.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:flutter/services.dart';

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
Future<bool> _showExitAppDialog(BuildContext context) async {
  return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Quitter l'application ?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Voulez-vous vraiment fermer l'application ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text("Annuler", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00292A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text("Oui", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
}
  @override
  Widget build(BuildContext context) {
     return WillPopScope(
      onWillPop: () async {
        return await _showExitAppDialog(context);
      },
    child: Scaffold(
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
      ),),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
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
