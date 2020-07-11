import 'dart:convert';

import 'package:app_news/settings/constants.dart';
import 'package:app_news/mainMenu.dart';
import 'package:app_news/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
    ));

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  String email, password;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http.post(Constants.url + 'login.php', body: {
      "email": email,
      "password": password,
    });

    final data = jsonDecode(response.body);
    String status = data["status"];
    String message = data["message"];
    if (status == 'berhasil') {
      String fullname = data["fullname"];
      String emailApi = data["email"];
      String userType = data["user_type"];
      String userId = data["user_id"];
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(
          status,
          fullname,
          emailApi,
          userType,
          userId,
        );
      });
      print(message);
    } else {
      print(message);
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  var hasil = '';
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      hasil = pref.getString('keyLogin');
      _loginStatus =
          (hasil == 'berhasil' ? LoginStatus.signIn : LoginStatus.notSignIn);
    });
  }

  signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString('keyLogin', '');
      pref.setString('fullname', '');
      pref.setString('email', '');
      pref.setString('user_type', '');
      pref.setString('user_id', '');
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  savePref(String value, String fullname, String emailApi, String userType,
      String userId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString('keyLogin', value);
      pref.setString('fullname', fullname);
      pref.setString('email', emailApi);
      pref.setString('user_type', userType);
      pref.setString('user_id', userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          appBar: AppBar(),
          body: Form(
              key: _key,
              child: ListView(
                padding: EdgeInsets.all(15.0),
                children: <Widget>[
                  TextFormField(
                    validator: (e) {
                      if (e.isEmpty) {
                        return "Email harap diisi!";
                      }

                      return null;
                    },
                    onSaved: (e) => email = e,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                  TextFormField(
                    validator: (e) {
                      if (e.isEmpty) {
                        return "Password harap diisi!";
                      }

                      return null;
                    },
                    obscureText: _secureText,
                    onSaved: (e) => password = e,
                    decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                            icon: Icon(_secureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: showHide)),
                  ),
                  MaterialButton(
                      onPressed: () {
                        check();
                      },
                      child: Text('Masuk')),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Register()));
                    },
                    child: Text(
                      'Create New Account',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )),
        );
        break;
      default:
        return MainMenu(signOut);
        break;
    }
  }
}
