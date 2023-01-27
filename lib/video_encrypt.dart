import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

import 'Utils.dart';

class VideoEncrypt extends StatefulWidget {
  const VideoEncrypt({super.key});

  @override
  State<StatefulWidget> createState() => _VideoEncryptState();
}

class _VideoEncryptState extends State<VideoEncrypt> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset("assets/video/bee.mp4");
    // controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Encrypt"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      pickVideo();
                    },
                    child: Text("Pick From Gallery")),
                ElevatedButton(
                    onPressed: () {
                      controller.pause();
                      controller.dispose();
                    },
                    child: Text("Stop")),
                ElevatedButton(
                    onPressed: () {
                      pickVideoFile();
                    },
                    child: const Text("Pick From File")),
              ],
            ),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: VideoPlayer(
                controller,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      encryptVideo();
                    },
                    child: const Text("Encrypt Video")),
                ElevatedButton(
                    onPressed: () {
                      decryptVideo();
                    },
                    child: const Text("Decrypt Video"))
              ],
            )
          ],
        ),
      ),
    );
  }

  void pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 10));

    if (video != null) {
      writeToFile(video.path);
      print("path ${video.path}");
      setState(() {
        playVideo(video.path);
      });
    }
  }

  void playVideo(String path) async {
    controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();
    setState(() {});
  }

  void encryptVideo() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testVideo.mp4"));
    bool _outputFileExists = await _outputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }

    File file = File(_outputFile.path);
    final _fileContents = file.readAsBytesSync();
    Encrypted result = await Utils.encryptFile(_fileContents);
    File encryptedFile = await _outputFile.writeAsBytes(result.bytes);
    print("Encryption Success");
    print(encryptedFile.path);
  }

  void decryptVideo() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testVideo.mp4"));
    bool _outputFileExists = await _outputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }
    File temp = File(_outputFile.path);
    var byteData = temp.readAsBytesSync();
    Encrypted encrypted = Encrypted(byteData);
    List<int> data = await Utils.decrypteFile(encrypted);

    File decryptedFile = await _outputFile.writeAsBytes(data);

    print("Decryption Success");
    print(decryptedFile!.path);
  }

  void pickVideoFile() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testVideo.mp4"));

    controller = VideoPlayerController.file(File(_outputFile.path));
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();
    setState(() {});
  }

  void writeToFile(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File _outputFile = File(p.join(dir.path, "testVideo.mp4"));
    bool _outputFileExists = await _outputFile.exists();

    if (!_outputFileExists) {
      await _outputFile.create();
    }
    File file = File(_outputFile.path);
    final _fileContents = file.readAsBytesSync();
    await _outputFile.writeAsBytes(_fileContents);
  }
}

class AspectRatioVideo extends StatefulWidget {
  final VideoPlayerController? controller;

  AspectRatioVideo({super.key, this.controller});

  @override
  State<StatefulWidget> createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller =>
      widget.controller ?? widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
