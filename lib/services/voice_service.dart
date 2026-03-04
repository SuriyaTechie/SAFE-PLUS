import 'dart:io';

import 'package:path_provider/path_provider.dart';

class VoiceService {
  Future<File> createDummyAudioFile() async {
    // Starter helper: creates a small dummy audio file for API testing.
    // Replace this with a real microphone recording flow later.
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/emergency_audio.wav');
    await file.writeAsBytes([1, 2, 3, 4, 5], flush: true);
    return file;
  }
}
