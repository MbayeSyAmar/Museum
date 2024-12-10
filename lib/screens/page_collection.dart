import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class Collection extends StatefulWidget {
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

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredKeys = collections.keys.toList();
      } else {
        filteredKeys = collections.keys
            .where((key) =>
                key.toLowerCase().contains(query.toLowerCase()))
            .toList();
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
                  // Barre de navigation avec recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (!isSearching)
                          Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 10),
                        if (!isSearching)
                          Expanded(
                            child: Text(
                              "Mes collections",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                              onItemTap: (item) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text("Détails de l'image"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
  if (item['url'] != null)
    item['url'].startsWith('http')
        ? Image.network(item['url']) // URL distante
        : item['url'].startsWith('assets/')
            ? Image.asset(item['url']) // Chemin des assets
            : Image.file(File(item['url'])), // Chemin local absolu
  SizedBox(height: 10),
  Text(item['description'] ?? "Aucune description"),
],


                                    ),
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
          bool unlocked = int.parse(key) <= points;

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
          : FileImage(File(item['url'])), // Chemin local absolu
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
