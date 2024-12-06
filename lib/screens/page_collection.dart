import 'package:flutter/material.dart';



class Collection extends StatefulWidget {
  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Map<String, dynamic>> sections = [
    {
      "title": "Impressionnistes",
      "elements": ["001", "002", "003", "image1", "image2", "001", "004", "005"]
    },
    {
      "title": "Stone & Cool",
      "elements": ["001", "image3", "006", "007", "image4", "001", "008", "009"]
    },
    {
      "title": "Take me to church",
      "elements": [
        "image5",
        "001",
        "image6",
        "010",
        "001",
        "011",
        "image7",
        "012"
      ]
    },
    {
      "title": "Abstract Arts",
      "elements": [
        "001",
        "013",
        "image8",
        "image9",
        "001",
        "014",
        "015",
        "image10"
      ]
    },
    {
      "title": "Modern Times",
      "elements": [
        "001",
        "image11",
        "016",
        "017",
        "image12",
        "001",
        "018",
        "019"
      ]
    },
    {
      "title": "Nature Vibes",
      "elements": [
        "image13",
        "001",
        "image14",
        "020",
        "021",
        "001",
        "image15",
        "022"
      ]
    }
  ];

  List<Map<String, dynamic>> filteredSections = [];
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredSections =
        sections; // Par défaut, toutes les sections sont visibles
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
            // Catégories
            Container(
              height: 80,
              child: ListView(
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
              child: ListView(
                children: filteredSections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: section['title']),
                      GridSection(
                        elements: section['elements'],
                        onItemTap: (item) {
                          if (item.startsWith('image')) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("Détail de l'image"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      "https://via.placeholder.com/150?text=$item",
                                    ),
                                    SizedBox(height: 10),
                                    Text("Très jolie"),
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
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                content: Text("Musée pas encore collecté."),
                                actions: [
                                  TextButton(
                                    child: Text("Fermer"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          }
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
                color: item.startsWith('image')
                    ? Colors.transparent
                    : Color(0xFFB7D6DD),
                borderRadius: BorderRadius.circular(10),
                image: item.startsWith('image')
                    ? DecorationImage(
                        image: NetworkImage(
                            "https://via.placeholder.com/150?text=$item"),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Center(
                child: item.startsWith('image')
                    ? null
                    : Text(
                        item,
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
