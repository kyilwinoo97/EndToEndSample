import 'package:end_to_end_sample/FileEncryption.dart';
import 'package:end_to_end_sample/audio_encrypt.dart';
import 'package:end_to_end_sample/show_image.dart';
import 'package:end_to_end_sample/text_encryption.dart';
import 'package:end_to_end_sample/video_encrypt.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'Utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E2EE Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EncryptionHome(),
      // home: Login(),
    );
  }
}

class EncryptionHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EncryptionHomeState();
}

class EncryptionHomeState extends State<EncryptionHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Encryption Sample"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TextEncryption()));
                    },
                    child: Text("Text Encryption")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ShowImage()));
                    },
                    child: const Text("Image Encryption")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AudioEncrypt()));
                    },
                    child: const Text("Audio Encryption")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const VideoEncrypt()));
                    },
                    child: const Text("Video Encryption")),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => FileEncryption()));
                  ///115792089237316195423570985008687907853269984665640564039457584007908834671663
                  print("p => ${Utils.p}");

                  ///7
                  //print("b => ${Utils.b}");

                  ///115792089237316195423570985008687907852837564279074904382605163141518161494337
                  //print("n => ${Utils.n}");

                  //var result = Utils.makeKeyPair();
                  // print("private key => ${result.item1}");
                  // print("public key => ${result.item2}");

                  // BigInt privateKey = BigInt.parse(
                  //     '6937741535887654265743324824034108375904433505174048585595165799285094610725808648988964494806251207039722899527312411813483137063453129819679768295838992');
                  //
                  // ///[96014020329034850550670814081589029153911124179238357537556942028204936825932, 33792938028682830385953294590596850512673866213068006243703038762022175626643]
                  // ///
                  // ///
                  // var bobPublicKey = Tuple2<BigInt, BigInt>(
                  //     BigInt.parse(
                  //         '15112744862433854155274584745483116330128540470544887862646599937480159354799'),
                  //     BigInt.parse(
                  //         '97695757141837815321440523935936255990942940439079723131880546704565330504677'));
                  // var finalCryptoKey =
                  //     Utils.scalar_mult(privateKey, bobPublicKey);
                  // print("final crypto key => $finalCryptoKey");

                  BigInt bobPrivateKey = BigInt.parse(
                      '10026856255706938967117726855050477874469715693156505920486751103168727882072415751560801676384745621647840515069594392648280603530741922700949532032443971');

                  //alice public key
                  BigInt x = BigInt.parse(
                      '96190653312500223738119574080367104895459949226265336653604253084254662860749');
                  BigInt y = BigInt.parse(
                      '42307508805848846030058171651789927051662335332321259746683283848178527634580');
                  var alicePublicKey = Tuple2<BigInt, BigInt>(x, y);
                  var finalKey =
                      Utils.scalar_mult(bobPrivateKey, alicePublicKey);
                  print("final key => $finalKey");

                  //64758380837719005731538696257662047943290079282268373282095823281861079219831
                  //45230823258673436227535011673919639409726867179913861006709395437907055711713
                },
                child: const Text("File Encryption"))
          ],
        ),
      ),
    );
  }
}
