import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'page_instruction.dart';
import 'page_instruction_question.dart';
import 'page_instruction_quizz.dart';
import 'oeuvre_retrouvee.dart';

class ParcoursNavigator extends StatefulWidget {
  final String courseId;
  final String userId;
  final String section;

  ParcoursNavigator({required this.courseId, required this.userId, required this.section});

  @override
  _ParcoursNavigatorState createState() => _ParcoursNavigatorState();
}

class _ParcoursNavigatorState extends State<ParcoursNavigator> {
  List<Map<String, dynamic>> courseItems = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCourseOrder();
  }

  Future<void> _loadCourseOrder() async {
    final courseRef = FirebaseFirestore.instance.collection("courses").doc(widget.courseId);
    final courseDoc = await courseRef.get();

    if (courseDoc.exists) {
      final courseData = courseDoc.data() as Map<String, dynamic>;
      if (courseData.containsKey("order")) {
        List<String> order = List<String>.from(courseData["order"]);
        List<Map<String, dynamic>> loadedItems = [];

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
            }
          }
        }
        if (!mounted) return;
        setState(() {
          courseItems = loadedItems;
          currentIndex = 0;
        });

        _navigateToNext();
      }
    }
  }

  Future<bool> _documentExists(String collectionPath, String docId) async {
    final doc = await FirebaseFirestore.instance.collection(collectionPath).doc(docId).get();
    return doc.exists;
  }

 void _navigateToNext() {
  if (!mounted) {
    print("❌ ERREUR: _navigateToNext() ne peut pas être exécuté car le widget n'est plus monté !");
    return;
  }

  if (currentIndex < courseItems.length) {
    final currentItem = courseItems[currentIndex];

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
            quiz: currentItem,
            onNext: _nextStep,
          ),
        ),
      );
    }
  } else {
    _finishCourse();
  }
}

void _nextStep() {
  if (!mounted) {
    print("❌ ERREUR: _nextStep() ne peut pas être exécuté car le widget n'est plus monté !");
    return;
  }

  print("📌 _nextStep() a été appelé avec currentIndex = $currentIndex");

  if (currentIndex < courseItems.length - 1) {
    setState(() {
      currentIndex++;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        print("📌 _navigateToNext() appelé depuis _nextStep()");
        _navigateToNext();
      }
    });
  } else {
    print("✅ Fin du parcours !");
    _finishCourse();
  }
}


  Future<void> _finishCourse() async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(widget.userId);
    await userRef.update({
      "collections.${widget.section}.${widget.courseId}.status": true, // ✅ Marquer le parcours comme terminé
    });

    // Récupérer les infos du parcours pour OeuvreRetrouvee
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

      // Trouver le prochain parcours dans la même section
      String nextAccessKey = 'Aucun parcours suivant';
      final coursesRef = FirebaseFirestore.instance.collection('courses');
      final sameSectionCourses = await coursesRef.where('section', isEqualTo: section).get();

      List<Map<String, dynamic>> sortedCourses = sameSectionCourses.docs
          .map((doc) => {'id': doc.id, 'accessKey': doc['accessKey']})
          .toList();

      sortedCourses.sort((a, b) => a['id'].compareTo(b['id']));

      for (int i = 0; i < sortedCourses.length; i++) {
        if (sortedCourses[i]['id'] == widget.courseId && i + 1 < sortedCourses.length) {
          nextAccessKey = sortedCourses[i + 1]['accessKey'];
          break;
        }
      }

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
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
