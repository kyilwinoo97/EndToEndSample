import 'package:dio/dio.dart';
import 'package:end_to_end_sample/Utils.dart';
import 'package:end_to_end_sample/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration:
                    InputDecoration(hintText: "Name", label: Text("Name")),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true, //This will obscure text dynamically
                decoration: InputDecoration(
                    hintText: "Password", label: Text("Password")),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    //Utils.makeKeyPair();
                    //postLogin();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Message()));
                  },
                  child: Text("Login"))
            ],
          ),
        ),
      ),
    );
  }

  void postLogin() async {
    Map<String, dynamic> data = {
      "userName": nameController.text,
      "password": passwordController.text
    };
    var result = await Dio().post(
        "http://206.233.240.12:8090/Api/GoldPotSlotMachine/Login",
        queryParameters: data);
    print(result.statusCode);
  }
}
