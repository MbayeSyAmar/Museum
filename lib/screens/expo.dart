import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:chat_app/screens/page_collection.dart';
import 'package:chat_app/screens/page_accueil.dart';
 import 'package:chat_app/screens/map_screen.dart';
  import 'package:chat_app/screens/profile.dart';

class Expo extends StatefulWidget {
  const Expo({super.key});

  @override
  State<Expo> createState() => _ExpoState();
}

class _ExpoState extends State<Expo> {
  List<Exhibition> exhibitions = [
    Exhibition(
      title: "Célébrité!",
      subtitle: "Objets de culte et star system",
      type: ExhibitionType.image,
      imagePath: "assets/images/image.png",
    ),
    Exhibition(
      title: "La culture skateboard",
      subtitle: "Des plages de Californie au Mucem",
      type: ExhibitionType.image,
      imagePath: "assets/images/image1.png",
    ),
    Exhibition(
      title: "La Chambre de Van Gogh à Arles",
      subtitle: "Une chambre bien rangée !",
      type: ExhibitionType.location,
      imagePath: "assets/images/image.png",
    ),
    Exhibition(
      title: "La Joconde",
      subtitle: "Elle a un regard bien mystérieux...",
      type: ExhibitionType.museum,
      imagePath: "assets/images/image1.png",
    ),
    Exhibition(
      title: "La Vénus",
      subtitle: "Vol direct pour la prochaine Fashion Week, ou bien ?",
      type: ExhibitionType.museum,
      imagePath: "assets/images/image1.png",
    ),
  ];

  void _deleteExhibition(int index) {
    setState(() {
      exhibitions.removeAt(index);
    });
  }

  void _selectExhibition(int index) {
    setState(() {
      for (var i = 0; i < exhibitions.length; i++) {
        exhibitions[i].isSelected = (i == index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(19, 50, 0, 7),
            color: const Color(0xFF00292A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Expositions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontFamily: 'Arcane Nine',
                  ),
                ),
                Text(
                  'expositions : 9',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Coolvetica',
                  ),
                ),
                // Text(
                //   '9',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 28,
                //     fontFamily: 'Coolvetica',
                //   ),
                //  ),
              ],
            ),
          ),

          // Exhibition List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(13),
              itemCount: exhibitions.length,
              itemBuilder: (context, index) {
                final exhibition = exhibitions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ExhibitionCard(
                    exhibition: exhibition,
                    onDelete: () => _deleteExhibition(index),
                    onTap: () => _selectExhibition(index),
                  ),
                );
              },
            ),
          ),
        ],
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
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF627474) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFDFDFD),
            fontSize: 14,
            fontFamily: 'Coolvetica',
          ),
        ),
      ],
    );
  }


class ExhibitionCard extends StatelessWidget {
  final Exhibition exhibition;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ExhibitionCard({
    super.key,
    required this.exhibition,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width * 0.25;

    return GestureDetector(
      onTap: onTap,
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.15,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                onDelete();
                // Delay the rebuild to ensure proper layout
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    Slidable.of(context)?.close();
                  }
                });
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
              child: const Icon(Icons.delete, size: 30),
            ),
          ],
        ),
        child: SizedBox(
          height: 75,
          child: Row(
            children: [
              // Left content (text)
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF014E4F),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: exhibition.isSelected
                            ? const Color(0xFF39CCD1)
                            : Colors.transparent,
                        width: 3,
                      ),
                      top: BorderSide(
                        color: exhibition.isSelected
                            ? const Color(0xFF39CCD1)
                            : Colors.transparent,
                        width: 3,
                      ),
                      bottom: BorderSide(
                        color: exhibition.isSelected
                            ? const Color(0xFF39CCD1)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: _buildIcon(exhibition.type),
                      ),
                      // Text content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exhibition.title,
                                style: const TextStyle(
                                  color: Color(0xFFFDFDFD),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Coolvetica',
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exhibition.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFFFDFDFD),
                                  fontSize: 14,
                                  fontFamily: 'Coolvetica',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right Image
              Container(
                width: imageWidth,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: exhibition.isSelected
                          ? const Color(0xFF39CCD1)
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: exhibition.isSelected
                          ? const Color(0xFF39CCD1)
                          : Colors.transparent,
                      width: 3,
                    ),
                    bottom: BorderSide(
                      color: exhibition.isSelected
                          ? const Color(0xFF39CCD1)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  image: DecorationImage(
                    image: AssetImage(exhibition.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildIcon(ExhibitionType type) {
  switch (type) {
    case ExhibitionType.museum:
      return const CircleAvatar(
          backgroundColor: Color(0xFF84ECF0), child: Text('M'));
    case ExhibitionType.location:
      return const CircleAvatar(backgroundColor: Color(0xFFFFE880));
    case ExhibitionType.image:
      return const CircleAvatar(backgroundColor: Colors.white);
  }
}

enum ExhibitionType { museum, location, image }

class Exhibition {
  final String title;
  final String subtitle;
  final ExhibitionType type;
  final String imagePath;
  bool isSelected;

  Exhibition({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.imagePath,
    this.isSelected = false,
  });
}
