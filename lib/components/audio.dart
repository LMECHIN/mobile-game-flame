import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_application_1/models/setting_data.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:provider/provider.dart';

class Audio extends Component with HasGameReference<PixelGame> {
  @override
  Future<void>? onLoad() async {
    FlameAudio.bgm.initialize();

    // await FlameAudio.audioCache
    //     .loadAll(['jump.ogg', 'fall.ogg', 'slide.ogg']);

    try {
      await FlameAudio.audioCache.load(
        'Level03.mp3',
      );
    } catch (_) {
      print('Failed');
    }

    return super.onLoad();
  }

  void playBgm(String filename) {
    if (!FlameAudio.audioCache.loadedFiles.containsKey(filename)) return;

    if (game.buildContext != null) {
      if (Provider.of<SettingData>(game.buildContext!, listen: false)
          .backgroundMusic) {
        FlameAudio.bgm.play(filename);
      }
    }
  }

  void playSfx(String filename) {
    if (game.buildContext != null) {
      if (Provider.of<SettingData>(game.buildContext!, listen: false)
          .soundEffects) {
        FlameAudio.play(filename);
      }
    }
  }

  void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  void resumeBgm() {
    FlameAudio.bgm.resume();
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }
}
