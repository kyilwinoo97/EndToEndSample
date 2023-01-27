import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FileEncryption extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FileEncryptionState();
}

class FileEncryptionState extends State<FileEncryption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Encryption"),
      ),
      body: Center(
        child: Column(
          children: const [
            Text("File Encryption"),
          ],
        ),
      ),
    );
  }
}
