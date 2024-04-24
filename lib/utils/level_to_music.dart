String levelToMusic(String? level) {
  String music = level!.replaceAll(".tmx", ".mp3");

  return music;
}
