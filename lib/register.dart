import 'dart:convert';

import 'package:app_news/settings/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email, password, name;
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
      save();
    }
  }

  save() async {
    final response = await http.post(Constants.url + 'register.php', body: {
      "username": name,
      "email": email,
      "password": password,
    });

    final data = jsonDecode(response.body);
    String status = data["status"];
    String message = data["message"];
    if (status == 'berhasil') {
      Navigator.pop(context);
    } else {
      print(message);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  return "Nama harap diisi!";
                }

                return null;
              },
              onSaved: (e) => name = e,
              decoration: InputDecoration(labelText: "Nama"),
            ),
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
                child: Text('Daftar ajah')),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Masuk',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
