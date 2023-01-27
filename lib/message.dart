import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class Message extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateMessage();
}

class StateMessage extends State<Message> {
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //todo handshake with sender
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              TextFormField(
                controller: messageController,
                obscureText: true, //This will obscure text dynamically
                decoration: const InputDecoration(
                    hintText: "Message", label: Text("Enter Message")),
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                // future: () {},
                builder: (
                  BuildContext context,
                  AsyncSnapshot<String> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Text('Error');
                    } else if (snapshot.hasData) {
                      return Text(snapshot.data!,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 36));
                    } else {
                      return const Text('Empty data');
                    }
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        var result = Utils.makeKeyPair();
                        var result2 = Utils.makeKeyPair();

                        var alicePrivateKey = result.item1;
                        var alicePublicKey = result.item2;

                        var bobPrivateKey = result2.item1;
                        var bobPublicKey = result2.item2;

                        print(
                            "alice private key " + alicePrivateKey.toString());
                        print("alice public key " + alicePublicKey.toString());

                        print("bob private key " + bobPrivateKey.toString());
                        print("bob public key " + bobPublicKey.toString());

                        var shareKey1 =
                            Utils.scalar_mult(alicePrivateKey, bobPublicKey);
                        var shareKey2 =
                            Utils.scalar_mult(bobPrivateKey, alicePublicKey);

                        print("Shared key1 " + shareKey1.toString());
                        print("Shared key2 " + shareKey2.toString());
                      },
                      child: const Text("Send Message")),
                  ElevatedButton(onPressed: () {}, child: Text("Get Message"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
