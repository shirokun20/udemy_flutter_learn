import 'dart:convert';

import 'package:app_news/models/newsModel.dart';
import 'package:app_news/settings/constants.dart';
import 'package:app_news/viewTabs/newsPages/addNews.dart';
import 'package:app_news/viewTabs/newsPages/editNews.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  var loading = false;
  final list = new List<NewsModel>();

  Future _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final res = await http.get(Constants.url + 'listNews.php');
    final data = jsonDecode(res.body);

    if (data['status'] == 'berhasil') {
      final output = data['data'];
      output.forEach((api) {
        final ab = new NewsModel(
            api['news_id'],
            api['news_image'],
            api['news_title'],
            api['news_content'],
            api['news_decs'],
            api['news_date'],
            api['users_id'],
            api['users_name']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    } else {
      print(data);
    }
  }

  _delete(String newsId) async {
    final response = await http
        .post(Constants.url + 'deleteNews.php', body: {'news_id': newsId});
    final data = jsonDecode(response.body);
    if (data['status'] == 'berhasil') {
      _lihatData();
    } else {
      print(data);
    }
  }

  dialogDelete(String newsId) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              children: <Widget>[
                Text('Apakah data ini ingin di hapus?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () => _delete(newsId),
                      child: Text('Yes'),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _lihatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddNews()));
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _lihatData();
        },
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final x = list[i];
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.network(
                                Constants.url + 'uploads/' + x.newsImage,
                                width: 150.0,
                                height: 150.0,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(x.newsTitle,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  Text(x.newsDate)
                                ],
                              )),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        EditNews(x, _lihatData),
                                  ));
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  dialogDelete(x.newsId);
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            color: Colors.pink,
                            height: 1,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
