import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'page_instruction.dart';
import 'page_instruction_question.dart';
import 'page_instruction_quizz.dart';
import 'page_accueil.dart';
import 'oeuvre_retrouvee.dart';

class ParcoursNavigator extends StatefulWidget {
  final String courseId;
  final String userId;
  final String section;
  final int startIndex;

  ParcoursNavigator({required this.courseId, required this.userId, required this.section, this.startIndex = 0,});

  @override
  _ParcoursNavigatorState createState() => _ParcoursNavigatorState();
}

class _ParcoursNavigatorState extends State<ParcoursNavigator> {
  List<Map<String, dynamic>> courseItems = [];
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    _loadCourseOrder();
  }

  Future<void> _loadCourseOrder() async {
  print("🔍 _loadCourseOrder() appelé pour le parcours ${widget.courseId}");

  final courseRef = FirebaseFirestore.instance.collection("courses").doc(widget.courseId);
  final courseDoc = await courseRef.get();

  if (!courseDoc.exists) {
    print(" Erreur: Aucun document trouvé pour ${widget.courseId} !");
    return;
  }

  final courseData = courseDoc.data() as Map<String, dynamic>;
  if (!courseData.containsKey("order")) {
    print(" Erreur: Pas de clé 'order' trouvée pour ${widget.courseId}");
    return;
  }

  List<String> order = List<String>.from(courseData["order"]);
  List<Map<String, dynamic>> loadedItems = [];

  print(" Ordre des éléments : $order");

  for (String itemId in order) {
    String? collectionType;
    
    if (await _documentExists("courses/${widget.courseId}/questions", itemId)) {
      collectionType = "questions";
    } else if (await _documentExists("courses/${widget.courseId}/quizzes", itemId)) {
      collectionType = "quizzes";
    } else if (await _documentExists("courses/${widget.courseId}/instructions", itemId)) {
      collectionType = "instructions";
    }

    if (collectionType != null) {
      final itemDoc = await FirebaseFirestore.instance
          .collection("courses/${widget.courseId}/$collectionType")
          .doc(itemId)
          .get();

      if (itemDoc.exists) {
        loadedItems.add({...itemDoc.data()!, "id": itemId, "type": collectionType});
      } else {
        print(" Erreur: Document $itemId non trouvé dans $collectionType !");
      }
    } else {
      print(" Erreur: Type inconnu pour $itemId");
    }
  }

  if (!mounted) return;

setState(() {
    courseItems = loadedItems;
    if (currentIndex == 0) { //  Ne pas écraser `currentIndex` si on a déjà avancé !
      currentIndex = widget.startIndex;
    }
  });

  print(" Contenu du parcours chargé : $courseItems");

  if (courseItems.isNotEmpty) {
    print("🚀 Lancement immédiat de _navigateToNext() après _loadCourseOrder()");
    _navigateToNext();
  } else {
    print(" Aucune donnée récupérée, _navigateToNext() ne sera pas exécuté !");
  }
}


  Future<bool> _documentExists(String collectionPath, String docId) async {
    final doc = await FirebaseFirestore.instance.collection(collectionPath).doc(docId).get();
    return doc.exists;
  }

void _navigateToNext() {
  if (!mounted) {
    print(" ERREUR: _navigateToNext() ne peut pas être exécuté car le widget n'est plus monté !");
    return;
  }
 print("🔄 Navigation vers l'élément index: $currentIndex / ${courseItems.length}");
  if (currentIndex < courseItems.length) {
    final currentItem = courseItems[currentIndex];
print("➡️ Élément actuel: ${currentItem["id"]}, type: ${currentItem["type"]}");
    if (currentItem["type"] == "instructions") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Instruction(
            instruction: currentItem,
            onNext: _nextStep,
          ),
        ),
      );
    } else if (currentItem["type"] == "questions") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionQuestion(
            question: {
              ...currentItem,
              "courseId": widget.courseId,
            },
            userId: widget.userId,
            onNext: _nextStep,
          ),
        ),
      );
    } else if (currentItem["type"] == "quizzes") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionQuizz(
            quiz: {
              ...currentItem, 
              "section": widget.section,  //  Ajout de la section
              "courseId": widget.courseId //  Ajout de l'ID du parcours
            },
            onNext: _nextStep,
          ),
        ),
      );
    }
  } else {
    _finishCourse();
  }
}



bool isNavigating = false; //  Empêche les doubles navigations

void _nextStep() {
  if (!mounted) {
    print(" ERREUR: _nextStep() ne peut pas être exécuté car le widget n'est plus monté !");
    return;
  }

  if (isNavigating) {
    print(" Navigation déjà en cours, _nextStep() annulé !");
    return;
  }

  isNavigating = true; //  Bloque les appels multiples

  print(" _nextStep() a été appelé avec currentIndex = $currentIndex");

  if (currentIndex < courseItems.length - 1) {
    setState(() {
      currentIndex++;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        print(" _navigateToNext() appelé depuis _nextStep()");
        _navigateToNext();
        isNavigating = false; //  Libère le blocage après la navigation
      }
    });
  } else {
    print("🎉 Fin du parcours !");
    _finishCourse();
    isNavigating = false; //  Assure que le blocage est levé à la fin
  }
}



 Future<void> _finishCourse() async {
  final userRef = FirebaseFirestore.instance.collection("users").doc(widget.userId);
  await userRef.update({
    "collections.${widget.section}.${widget.courseId}.status": true, //  Marquer le parcours comme terminé
  });

  //  **Récupérer les infos du parcours pour OeuvreRetrouvee**
  final courseRef = FirebaseFirestore.instance.collection("courses").doc(widget.courseId);
  final courseSnapshot = await courseRef.get();

  if (courseSnapshot.exists) {
    final courseData = courseSnapshot.data();

    final title = courseData?['title'] ?? 'Titre inconnu';
    final section = courseData?['section'] ?? 'Section inconnue';
    final description = courseData?['description'] ?? 'Pas de description';
    final musee = courseData?['musee'] ?? 'Musée inconnu';
    final createdAtTimestamp = courseData?['createdAt'];
    final imageUrl = courseData?['imageUrl'] ?? 'https://via.placeholder.com/150';

    String createdAt = 'Date inconnue';
    if (createdAtTimestamp != null) {
      final date = createdAtTimestamp.toDate();
      createdAt = "${date.day} ${_getMonthName(date.month)} ${date.year}";
    }

    //  **Trouver le prochain parcours dans la même section**
    String nextAccessKey = 'Aucun parcours suivant';
    final coursesRef = FirebaseFirestore.instance.collection('courses');

    final sameSectionCourses = await coursesRef.where('section', isEqualTo: section).get();
    List<Map<String, dynamic>> sortedCourses = sameSectionCourses.docs
        .map((doc) => {'id': doc.id, 'accessKey': doc['accessKey']})
        .toList();

    // **Trier les parcours par ordre d'ajout (ou par ID si applicable)**
    sortedCourses.sort((a, b) => a['id'].compareTo(b['id']));

    // 🔍 **Chercher le parcours suivant**
    for (int i = 0; i < sortedCourses.length; i++) {
      if (sortedCourses[i]['id'] == widget.courseId && i + 1 < sortedCourses.length) {
        nextAccessKey = sortedCourses[i + 1]['accessKey']; //  Récupération de la clé d’accès
        break;
      }
    }

    print(" Clé du parcours suivant : $nextAccessKey");

    //  **Naviguer vers `OeuvreRetrouvee` avec les bonnes infos**
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OeuvreRetrouvee(
          title: title,
          section: section,
          description: description,
          musee: musee,
          createdAt: createdAt,
          imageUrl: imageUrl,
          nextAccessKey: nextAccessKey,
        ),
      ),
    );
  }
}


  String _getMonthName(int month) {
    const monthNames = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return monthNames[month];
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      print("🔙 Bouton retour pressé !");
      return await _showExitGameDialog(context);
    },
    child: Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

///  Fonction qui affiche un pop-up avant de quitter le jeu
Future<bool> _showExitGameDialog(BuildContext context) async {
  print("🛑 Affichage du pop-up de sortie du jeu...");
  return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Quitter le jeu ?"),
            content: Text("Vous allez être redirigé vers la page d'accueil."),
            actions: [
              TextButton(
                onPressed: () {
                  print("🚫 Annulation du retour");
                  Navigator.pop(context, false);
                },
                child: Text("Annuler"),
              ),
              TextButton(
                onPressed: () {
                  print(" Navigation vers la page d'accueil...");
                  Navigator.pop(context, true);

                  // 🚀 Redirection propre vers la page d'accueil
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text("Oui"),
              ),
            ],
          );
        },
      ) ??
      false; // Retourne false si l'utilisateur ferme le pop-up
}


}
