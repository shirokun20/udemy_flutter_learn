import 'dart:io';
import 'package:app_news/settings/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:async/async.dart';
class AddNews extends StatefulWidget {
  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  File _imgFile;

  String title, desc, content, userId;

  final picker = ImagePicker();

  final _key = new GlobalKey<FormState>();

  _pilihGallery() async {
    final image = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1920,
    );

    if (image != null) {
      setState(() {
        _imgFile = File(image.path);
      });
    }
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      submit();
    }
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userId = pref.getString('user_id');
    });
  }

  submit() async {
    try {
      var stream = http.ByteStream(Stream.castFrom(_imgFile.openRead()));
      var length = await _imgFile.length();
      var uri = Uri.parse(Constants.url + 'addNews.php');
      var req = http.MultipartRequest("POST", uri);
      req.files.add(http.MultipartFile("image", stream, length,
          filename: path.basename(_imgFile.path)));
      req.fields['title'] = title;
      req.fields['content'] = content;
      req.fields['desc'] = desc;
      req.fields['user_id'] = userId;

      var res = await req.send();

      if (res.statusCode > 2) {
        print('Upload Sukses');
        setState(() {
          Navigator.pop(context);
        });
      } else {
        print('Upload Gagal');
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    var placeHolder = Container(
      width: double.infinity,
      height: 150,
      child: Image.asset('./image/upload.png'),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    _pilihGallery();
                  },
                  child: _imgFile == null
                      ? placeHolder
                      : Image.file(
                          _imgFile,
                          fit: BoxFit.fill,
                        ),
                )),
            TextFormField(
              onSaved: (e) => title = e,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              onSaved: (e) => content = e,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            TextFormField(
              onSaved: (e) => desc = e,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
