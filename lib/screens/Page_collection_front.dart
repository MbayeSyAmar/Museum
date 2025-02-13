import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';




class Collection extends StatefulWidget {
  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> filteredSections = [];
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  // Fonction pour récupérer les sections depuis Firestore


void fetchSections() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser; // Récupère l'utilisateur connecté

  if (user == null) {
    print("Aucun utilisateur connecté");
    return;
  }

  String userId = user.uid; // Récupère l'ID de l'utilisateur connecté

  QuerySnapshot snapshot = await firestore
      .collection('users')
      .doc(userId) // Utilisation dynamique de l'ID utilisateur
      .get()
      .then((doc) => doc.reference.collection('collections').get());

  List<Map<String, dynamic>> fetchedSections = [];

  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    fetchedSections.add({
      "title": doc.id, // Nom de la section
      "elements": data.keys.toList(), // Récupère les clés des éléments
    });
  }

  setState(() {
    sections = fetchedSections;
    filteredSections = sections; // Mise à jour des sections affichées
  });
}


  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSections = sections;
      } else {
        filteredSections = sections
            .where((section) =>
                section['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        filteredSections = sections;
        searchQuery = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A2B32),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de navigation avec recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (!isSearching) Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(width: 10),
                  if (!isSearching)
                    Expanded(
                      child: Text(
                        "Mes collection",
                         style: const TextStyle(
              fontFamily: 'Arcane Nine',
              fontSize: 64,
              fontWeight: FontWeight.w400,
              height: 1.0,
              color: Colors.white,
            ),
                      ),
                    ),
                  if (isSearching)
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A2B32),
                          border: Border.all(color: Colors.white, width: 1),
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
                  IconButton(
                    icon: Icon(isSearching ? Icons.close : Icons.search,
                        color: Colors.white),
                    onPressed: toggleSearch,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Catégories
            Container(
              height: 80,
              child: filteredSections.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredSections.map((section) {
                        return GestureDetector(
                          onTap: () => moveSectionToTop(section),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.museum, color: Colors.white, size: 50),
                                SizedBox(height: 5),
                                Text(
                                  section['title'],
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            SizedBox(height: 10),
            // Sections filtrées
            Expanded(
              child: filteredSections.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                      children: filteredSections.map((section) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(title: section['title']),
                            GridSection(
                              elements: section['elements'],
                              onItemTap: (item) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    content: Text("Élément sélectionné : $item"),
                                    actions: [
                                      TextButton(
                                        child: Text("Fermer"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  void moveSectionToTop(Map<String, dynamic> section) {
    setState(() {
      filteredSections.remove(section);
      filteredSections.insert(0, section);
    });
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
  final List<String> elements;
  final Function(String) onItemTap;
  GridSection({required this.elements, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
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
        itemCount: elements.length,
        itemBuilder: (context, index) {
          final item = elements[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFB7D6DD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
