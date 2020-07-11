import 'dart:io';

import 'package:app_news/models/newsModel.dart';
import 'package:app_news/settings/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class EditNews extends StatefulWidget {
  final NewsModel model;
  final VoidCallback reload;
  EditNews(this.model, this.reload);
  @override
  _EditNewsState createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews> {
  File _imgFile;

  String title, desc, content, userId;
  TextEditingController txtTitle, txtDesc, txtContent;
  final _key = new GlobalKey<FormState>();

  final picker = ImagePicker();

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

  submit() async {
    try {
      var stream = http.ByteStream(Stream.castFrom(_imgFile.openRead()));
      var length = await _imgFile.length();
      var uri = Uri.parse(Constants.url + 'editNews.php');
      var req = http.MultipartRequest("POST", uri);
      req.files.add(http.MultipartFile("image", stream, length,
          filename: path.basename(_imgFile.path)));
      req.fields['title'] = title;
      req.fields['content'] = content;
      req.fields['desc'] = desc;
      req.fields['user_id'] = userId;
      req.fields['news_id'] = widget.model.newsId;

      var res = await req.send();

      if (res.statusCode > 2) {
        print('Upload Sukses');
        widget.reload();
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

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userId = pref.getString('user_id');
    });

    txtTitle = TextEditingController(text: widget.model.newsTitle);
    txtDesc = TextEditingController(text: widget.model.newsDesc);
    txtContent = TextEditingController(text: widget.model.newsContent);
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            Container(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    _pilihGallery();
                  },
                  child: _imgFile == null
                      ? Image.network(
                          Constants.url + '/uploads/' + widget.model.newsImage)
                      : Image.file(
                          _imgFile,
                          fit: BoxFit.fill,
                        ),
                )),
            TextFormField(
              controller: txtTitle,
              onSaved: (e) => title = e,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextFormField(
              controller: txtContent,
              onSaved: (e) => content = e,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            TextFormField(
              controller: txtDesc,
              onSaved: (e) => desc = e,
              decoration: InputDecoration(
                labelText: 'Desciption',
              ),
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
