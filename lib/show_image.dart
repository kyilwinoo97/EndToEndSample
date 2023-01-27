import 'dart:io';

import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:end_to_end_sample/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ShowImage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShowImageState();
}

class ShowImageState extends State<ShowImage> {
  XFile? selectedImage;
  File? encryptedFile;
  File? decryptedFile;
  Encrypted? encryptedResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Image"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Text("Pick Image")),
              ElevatedButton(
                  onPressed: () async {
                    if (selectedImage != null) {
                      Directory dir = await getApplicationDocumentsDirectory();
                      File _outputFile = File(p.join(dir.path, "image.png"));
                      bool _outputFileExists = await _outputFile.exists();

                      if (!_outputFileExists) {
                        await _outputFile.create();
                      }

                      File file = File(selectedImage!.path);
                      final _fileContents = file.readAsBytesSync();

                      //file compression
                      var compressedContent =
                          GZipDecoder().decodeBytes(_fileContents.toList());

                      Encrypted result = await Utils.encryptFile(_fileContents);
                      File encryptedFile =
                          await _outputFile.writeAsBytes(result.bytes);
                      print(encryptedFile.path);
                      setState(() {
                        encryptedResult = result;
                        this.encryptedFile = encryptedFile;
                        decryptedFile = null;
                      });
                    }
                  },
                  child: Text("Encrypt Image")),
              ElevatedButton(
                  onPressed: () async {
                    Directory dir = await getApplicationDocumentsDirectory();
                    File _outputFile = File(p.join(dir.path, "image.png"));
                    bool _outputFileExists = await _outputFile.exists();

                    if (!_outputFileExists) {
                      await _outputFile.create();
                    }

                    //file decompression
                    var compressedContent;
                    compressedContent =
                        GZipEncoder().encode(encryptedResult!.bytes.toList())!;

                    List<int> data = await Utils.decrypteFile(encryptedResult!);

                    File decryptedFile = await _outputFile.writeAsBytes(data);
                    setState(() {
                      this.decryptedFile = decryptedFile;
                    });
                    print(this.decryptedFile!.path);
                  },
                  child: Text("Decrypt Image")),
            ]),
            selectedImage != null
                ? Image.file(
                    File(selectedImage!.path),
                    width: 100,
                    height: 200,
                  )
                : SizedBox.shrink(),
            const SizedBox(
              height: 20,
            ),
            decryptedFile != null
                ? Image.file(
                    File(decryptedFile!.path),
                    width: 100,
                    height: 200,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }
}
