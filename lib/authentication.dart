import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:settle_assessment/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool hidePassword = true;
  bool isUserValid;

  _AuthenticationPageState() {
    SharedPreferences.getInstance()
        .then((value) => setState(() => isUserValid = value.getBool(kUser)))
        .whenComplete(() {
      if (isUserValid == null)
        setState(() => isUserValid = false);
      else if (isUserValid == true)
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyHomePage();
        })).whenComplete(() => isValid = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: new Container(
                  decoration:
                      new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
              if (isUserValid == null)
                Center(child: CircularProgressIndicator()),
              if (isUserValid == false)
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("User Location Tracker",
                              textAlign: TextAlign.center,
                              style: whiteStyle.copyWith(fontSize: 28)),
                        ),
                        Divider(
                            indent: 100,
                            endIndent: 100,
                            color: Colors.white,
                            height: 18),
                        TextFormField(
                          controller: _username,
                          style: whiteStyle,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelStyle: whiteStyle,
                            labelText: "Username",
                            enabledBorder: new UnderlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        TextFormField(
                          controller: _password,
                          style: whiteStyle,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              child: Icon(
                                  hidePassword
                                      ? Icons.remove_red_eye
                                      : Icons.remove_red_eye_outlined,
                                  color: white),
                              onTap: () =>
                                  setState(() => hidePassword = !hidePassword),
                            ),
                            labelStyle: whiteStyle,
                            labelText: "Password",
                            enabledBorder: new UnderlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 20),
                        RaisedButton(
                          onPressed: () {
                            SharedPreferences.getInstance().then((value) =>
                                value.setString(kUsername, _username.text));
                            if (_formKey.currentState.validate()) {
                              isValid = true;
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage()))
                                  .whenComplete(() => isValid = false);
                            }
                          },
                          child: Text("Login"),
                        ),
                        SizedBox(height: 90),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  set isValid(bool result) => SharedPreferences.getInstance().then((value) {
        value.setBool(kUser, result);
        setState(() => isUserValid = result);
      }).whenComplete(() {
        _username.text = "";
        _password.text = "";
      });
}

final TextStyle whiteStyle = TextStyle(color: Colors.white, fontSize: 18);
