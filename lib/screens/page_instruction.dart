import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/screens/music_manager.dart';
import 'package:chat_app/screens/page_accueil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:async';

class Instruction extends StatefulWidget {
  final Map<String, dynamic> instruction;
  final VoidCallback onNext;

  Instruction({required this.instruction, required this.onNext});

  @override
  _InstructionState createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  String _displayedText = '';
  late String _fullText;
  int _currentIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fullText = widget.instruction["text"] ??
        "Aucune instruction disponible."; // Récupérer le texte de l'instruction
    _startMusic();
    _startTextAnimation();
  }

  Future<void> _startMusic() async {
    await MusicManager.playMusic();
    await MusicManager.setVolume(0.1);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTextAnimation() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/typing.mp3'));

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _audioPlayer.stop();
      }
    });
  }

  void _skipTextAnimation() {
    setState(() {
      _displayedText = _fullText;
      _currentIndex = _fullText.length;
    });
    _audioPlayer.stop();
    _timer?.cancel();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitInstructionDialog(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B2425),
        body: Stack(
          children: [
            //  Image ajustée pour occuper tout le cadre sans être coupée
            Positioned(
              top: 90, //  Ajustement de la position
              left: 20,
              right: 20,
              bottom: 155, //  Ajustement de la hauteur
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
                ),
                child: ClipRect(
                  child: widget.instruction["imageUrl"] != null
                      ? SizedBox.expand(
                          //  L'image prend toute la place du cadre
                          child: FittedBox(
                            fit: BoxFit.fill, //  Remplit tout sans être coupée
                            child:
                                Image.network(widget.instruction["imageUrl"]),
                          ),
                        )
                      : SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Image.asset(
                                'assets/images/background_hint.png'),
                          ),
                        ),
                ),
              ),
            ),
            //  Remplacement de l'icône "Run" par un SVG
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () async {
                  bool exit = await _showExitInstructionDialog(context);
                  if (exit) {
                    Navigator.pop(context);
                  }
                },
                child: SvgPicture.asset(
                  'assets/images/mdi_run-fast.svg', //  Remplacement par le SVG
                  width: 36,
                  height: 36,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFFDB3D),
                    BlendMode.srcIn, //  Applique la couleur jaune
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 30,
                  left: 25,
                  right: 55,
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00292A),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.elliptical(20, 20),
                        topLeft: Radius.elliptical(20, 20),
                        topRight: Radius.elliptical(4, 4),
                        bottomLeft: Radius.elliptical(4, 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 40,
                  right: 50,
                  child: GestureDetector(
                    onTap: _skipTextAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: const Color(0xFF00292A),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.elliptical(20, 20),
                          topLeft: Radius.elliptical(20, 20),
                          topRight: Radius.elliptical(4, 4),
                          bottomLeft: Radius.elliptical(4, 4),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _displayedText,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Coolvetica',
                        ),
                        softWrap: true,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 20, //  Ajout de la flèche de retour à gauche
              child: GestureDetector(
                onTap: _previousInstruction,
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFFFDB3D),
                  size: 36,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _audioPlayer.stop();
                  widget.onNext;
                }, //  Passer à l'étape suivante
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFFFFDB3D),
                  size: 36,
                ),
              ),
            ),
            // Positioned(
            //   bottom: 150,
            //   left: 10,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFFFFDB3D),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: const Text(
            //       'Gérart',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 20,
            //         fontFamily: 'Arcane Nine',
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _previousInstruction() {
    if (mounted) {
      print(" Retour à l'instruction précédente...");
      Navigator.pop(context); // 🔄 Retourner à l'étape précédente
    }
  }

  ///  Fonction pour afficher le pop-up de retour vers l’accueil
  Future<bool> _showExitInstructionDialog(BuildContext context) async {
    return await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    color:
                        Colors.black.withOpacity(0.3), // Fond semi-transparent
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
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
                        Icon(Icons.exit_to_app,
                            size: 50, color: Colors.redAccent),
                        SizedBox(height: 10),
                        Text(
                          "Quitter le parcours ?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Voulez-vous retourner à l'accueil ? Votre progression sera sauvegardée.",
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
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text("Annuler",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _audioPlayer.stop(); //
                                  Navigator.pop(context, true);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text("Oui",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
