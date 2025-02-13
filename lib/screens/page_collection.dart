import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class Collection extends StatefulWidget {
  const Collection({super.key});
  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
 late User? currentUser;
  late FirebaseFirestore firestore;
  int points = 0;
  Map<String, dynamic> collections = {};
  List<String> filteredKeys = [];
  bool isSearching = false;
  String searchQuery = "";
  bool isFilterMenuVisible = false; // Gérer l'affichage du menu de filtres
  String selectedFilter = "Par collection (numéros)"; // Valeur par défaut

  List<String> filterOptions = [
    "Par collection (numéros)",
    "Par musée",
    "Par titre d'œuvre",
  ];

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    currentUser = FirebaseAuth.instance.currentUser;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          points = userDoc['points'] ?? 0;
          collections = userDoc['collections'] ?? {};
          filteredKeys = collections.keys.toList(); // Initialisation
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void toggleFilterMenu() {
    setState(() {
      isFilterMenuVisible = !isFilterMenuVisible;
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      isFilterMenuVisible = false; // Masquer le menu après la sélection
    });

    print("Filtrage appliqué: $filter");
    // Ajoute ici la logique pour filtrer les collections
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredKeys = collections.keys.toList();
      } else {
        filteredKeys = collections.keys.where((key) {
          bool matchesCollection = key.toLowerCase().contains(query.toLowerCase());
          bool matchesTitle = collections[key].values.any((item) =>
              item['titre'] != null &&
              item['titre'].toLowerCase().contains(query.toLowerCase()));

          return matchesCollection || matchesTitle;
        }).toList();
      }
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        filteredKeys = collections.keys.toList();
        searchQuery = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A2B32),
      body: SafeArea(
        child: collections.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Barre de navigation avec recherche et filtre
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MON MUSÉE",
                          style: const TextStyle(
                            fontFamily: 'Arcane Nine',
                            fontSize: 54,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: toggleFilterMenu,
                              child: Row(
                                children: [
                                  Icon(Icons.filter_list, color: Colors.white, size: 24),
                                  SizedBox(width: 5),
                                  Text(
                                    "Filtrer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                isSearching ? Icons.close : Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: toggleSearch,
                            ),
                          ],
                        ),
                        // Ligne blanche après Filtrer & Recherche
                        SizedBox(height: 10),
                        Container(
                          height: 2,
                          color: Colors.white.withOpacity(0.5),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        // Affichage du menu de filtre si activé
                        if (isFilterMenuVisible)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: filterOptions.map((option) {
                                return GestureDetector(
                                  onTap: () => applyFilter(option),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: selectedFilter == option
                                          ? Colors.cyan
                                          : Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          option,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Spacer(),
                                        if (selectedFilter == option)
                                          Icon(Icons.check, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Barre de recherche affichée uniquement si active
                        if (isSearching)
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              width: double.infinity,
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                autofocus: true,
                                onChanged: updateSearch,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Rechercher...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  // Liste horizontale des catégories
                  Container(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredKeys.map((key) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            filteredKeys.remove(key);
                            filteredKeys.insert(0, key);
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.museum, color: Colors.white, size: 50),
                                SizedBox(height: 5),
                                Text(
                                  key,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Ligne blanche après la liste des collections
                  SizedBox(height: 10),
                  Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.5),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  SizedBox(height: 10),
                  // Liste des collections filtrées
                  Expanded(
                    child: ListView(
                      children: filteredKeys.map((collectionName) {
                        Map<String, dynamic> elements =
                            collections[collectionName] as Map<String, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(title: collectionName),
                            GridSection(
                              elements: elements,
                              points: points,
                              onItemTap: onItemTap,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  void onItemTap(Map<String, dynamic> item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool isFavorite = false; // Déclare l'état ici pour qu'il soit réactif
      return StatefulBuilder(
        builder: (context, setState) {

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  // Image de fond
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item['url'] != null
                          ? (item['url'].startsWith('http')
                              ? Image.network(item['url'], fit: BoxFit.cover)
                              : item['url'].startsWith('assets/')
                                  ? Image.asset(item['url'], fit: BoxFit.cover)
                                  : Image.file(File(item['url']), fit: BoxFit.cover))
                          : Container(color: Colors.grey[300]),
                    ),
                  ),
                  // Overlay en dégradé
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF00292A)],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Icône étoile SVG cliquable
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite; // Change l'état du favori
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/images/star.svg',
                        width: 50,
                        height: 50,
                        colorFilter: ColorFilter.mode(
                          isFavorite ? Colors.yellow : Colors.white,
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                  ),
                  // Indicateur de pull
                  Positioned(
                    left: 155,
                    top: 11,
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Contenu du pop-up
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF00292A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['titre'] ?? "Titre inconnu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            item['description'] ?? "Aucune description",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFB7D6DD),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'En savoir plus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF84ECF0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.collections,
                                          color: Color(0xFF39313C),
                                          size:
                                              MediaQuery.of(context).size.width *
                                                  0.04,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Voir la collection',
                                          style: TextStyle(
                                            color: Color(0xFF39313C),
                                            fontSize:
                                                MediaQuery.of(context).size.width *
                                                    0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

}

class SectionTitle extends StatelessWidget {
  final String title;
  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: Color(0xFFFFC107),
              margin: EdgeInsets.only(left: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class GridSection extends StatelessWidget {
  final Map<String, dynamic> elements;
  final int points;
  final Function(Map<String, dynamic>) onItemTap;

  GridSection({
    required this.elements,
    required this.points,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> keys = elements.keys.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          String key = keys[index];
          Map<String, dynamic> item = elements[key];
          bool unlocked = item['status'] == true; // Basé sur le statut

          return GestureDetector(
            onTap: unlocked ? () => onItemTap(item) : null,
            child: Container(
              decoration: BoxDecoration(
                color: unlocked ? Colors.transparent : Color(0xFFB7D6DD),
                borderRadius: BorderRadius.circular(10),
                image: unlocked && item['url'] != null
                    ? DecorationImage(
                        image: item['url'].startsWith('http')
                            ? NetworkImage(item['url']) // URL distante
                            : item['url'].startsWith('assets/')
                                ? AssetImage(item['url']) // Chemin des assets
                                : FileImage(File(item['url'])), // Chemin local
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Center(
                child: unlocked
                    ? null
                    : Text(
                        key,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
