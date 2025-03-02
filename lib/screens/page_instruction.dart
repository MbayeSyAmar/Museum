import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/screens/music_manager.dart';
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
    _fullText = widget.instruction["text"] ?? "Aucune instruction disponible."; // Récupérer le texte de l'instruction
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2425),
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 10,
            right: 10,
            bottom: 150,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFDB3D), width: 2),
              ),
              child: ClipRect(
                child: widget.instruction["imageUrl"] != null
                    ? Image.network(
                        widget.instruction["imageUrl"],
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/background_hint.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.directions_run,
                color: Colors.white,
                size: 36,
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
                    color: const Color(0xFF39C9D0),
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
                bottom: 32,
                left: 20,
                right: 60,
                child: GestureDetector(
                  onTap: _skipTextAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                        color: Colors.blue,
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
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: widget.onNext, // 🔥 Passer à l'étape suivante
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
                size: 36,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB3D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Gérart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Arcane Nine',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
