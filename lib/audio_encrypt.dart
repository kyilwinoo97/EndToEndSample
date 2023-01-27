import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

import 'Utils.dart';

class AudioEncrypt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AudioEncryptState();
}

class _AudioEncryptState extends State<AudioEncrypt> {
  Record _audioRecorder = Record();
  AudioPlayer player = AudioPlayer();
  Encrypted? encryptedResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Encryption"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Icon(
              Icons.audiotrack_rounded,
              color: Colors.red,
              size: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                    onPressed: () {
                      startRecording();
                    },
                    child: const Text("Record")),
                ElevatedButton(
                    onPressed: () {
                      stopRecording();
                    },
                    child: const Text("Stop"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                    onPressed: () {
                      playAudio();
                    },
                    child: const Text("Play")),
                ElevatedButton(
                    onPressed: () {
                      stopAudio();
                    },
                    child: const Text("Stop"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                    onPressed: () {
                      encryptAudio();
                    },
                    child: const Text("Encrypt Audio")),
                ElevatedButton(
                    onPressed: () {
                      decryptAudio();
                    },
                    child: const Text("Decrypt Audio"))
              ],
            )
          ],
        ),
      ),
    );
  }

  void encryptAudio() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testAudio.mp3"));
    bool _outputFileExists = await _outputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    File file = File(_outputFile.path);
    final _fileContents = file.readAsBytesSync();
    Encrypted result = await Utils.encryptFile(_fileContents);
    File encryptedFile = await _outputFile.writeAsBytes(result.bytes);
    print(encryptedFile.path);
    print("Encryption Success");
    setState(() {
      encryptedResult = result;
    });
  }

  void decryptAudio() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testAudio.mp3"));
    bool _outputFileExists = await _outputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    List<int> data = await Utils.decrypteFile(encryptedResult!);

    File decryptedFile = await _outputFile.writeAsBytes(data);
    // setState(() {
    //   this.decryptedFile = decryptedFile;
    // });
    print("Decryption Success");
    print(decryptedFile!.path);
  }

  void playAudio() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testAudio.mp3"));
    bool fileExists = await _outputFile.exists();
    if (fileExists) {
      try {
        await player.play(DeviceFileSource(_outputFile.path));
      } catch (exception) {
        print(exception.toString());
      }
    }
  }

  void stopAudio() async {
    await player.stop();
  }

  void startRecording() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.storage,
      Permission.microphone,
    ].request();
    bool permissionsGranted = permissions[Permission.storage]!.isGranted &&
        permissions[Permission.microphone]!.isGranted;

    if (permissionsGranted) {
      Directory dir = await getApplicationDocumentsDirectory();
      File _outputFile = File(p.join(dir.path,
          "testAudio.mp3")); //${ DateTime.now().millisecondsSinceEpoch.toString()}
      // final filepath = Paths.recording +
      //     '/' +
      //     DateTime.now().millisecondsSinceEpoch.toString() +
      //     '.rn'
      bool _outputFileExists = await _outputFile.exists();
      if (!_outputFileExists) {
        await _outputFile.create();
      }
      await _audioRecorder.start(path: _outputFile.path);
    }
  }

  void stopRecording() async {
    String? path = await _audioRecorder.stop();
    print('Output path $path');
  }

  Stream<double> amplitudeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      final ap = await _audioRecorder.getAmplitude();
      yield ap.current;
    }
  }
}
