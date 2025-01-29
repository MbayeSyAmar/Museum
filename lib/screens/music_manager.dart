import 'package:audioplayers/audioplayers.dart';

class MusicManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Joue la musique en boucle
  static Future<void> playMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Répéter la musique
    await _audioPlayer.play(AssetSource('sounds/background_music.mp3'));
  }

  /// Arrête la musique
  static Future<void> stopMusic() async {
    await _audioPlayer.stop();
    print("Music stopped.");
  }

  /// Modifie le volume (entre 0.0 et 1.0)
  static Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError("Volume must be between 0.0 and 1.0");
    }
    await _audioPlayer.setVolume(volume);
  }
    static Future<void> correctMusic() async {
    // await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Répéter la musique
    await _audioPlayer.play(AssetSource('sounds/correct_sound.mp3'));
  }
   static Future<void> errorMusic() async {
    // await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Répéter la musique
    await _audioPlayer.play(AssetSource('sounds/error_sound.mp3'));
  }
}
