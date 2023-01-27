import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class TextEncryption extends StatefulWidget {
  const TextEncryption({super.key});

  @override
  State<TextEncryption> createState() => _TextEncryptionState();
}

class _TextEncryptionState extends State<TextEncryption> {
  BigInt p = BigInt.parse(
      "12343254351345093244323432543535923345342534523453425324534566546567546546465435234534523453245324523453453425346575675686788567763565436345634643563466059767304757");
  BigInt g = BigInt.parse("123432543513450932443059767304757");
  String text = "";
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    //  createPrivateRandomNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Encryption"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: TextField(
                controller: controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        text = await Utils.encryptAES(controller.text);
                        setState(() {});
                      }
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        child: const Text("Encrypt"))),
                ElevatedButton(
                    onPressed: () async {
                      var tempText = await Utils.decryptAES(text);
                      setState(() {
                        text = tempText;
                      });
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        child: Text("Decrypt")))
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void createPrivateRandomNumber() {
    BigInt key = randomBigInt();

    BigInt swapKey = mixKey(g, key, p);
    print("swap key");
    print(swapKey);
  }

  BigInt mixKey(BigInt base, BigInt power, BigInt mod) {
    print("base");
    print(base);
    print("power");
    print(power);

    print("mod");
    print(mod);
    return base.modPow(power, mod);
  }

  BigInt randomBigInt() {
    const size = 128;
    final random = Random.secure();
    final builder = BytesBuilder();
    for (var i = 0; i < size; ++i) {
      builder.addByte(random.nextInt(256));
    }
    final bytes = builder.toBytes();
    return readBytes(bytes);
  }

  BigInt readBytes(Uint8List bytes) {
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        for (int i = end - 1; i >= start; i--) {
          result = result * 256 + bytes[i];
        }
        return BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      var result = read(start, mid) +
          read(mid, end) * (BigInt.one << ((mid - start) * 8));
      return result;
    }

    return read(0, bytes.length);
  }
}
