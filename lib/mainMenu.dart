import 'package:app_news/viewTabs/category.dart';
import 'package:app_news/viewTabs/home.dart';
import 'package:app_news/viewTabs/news.dart';
import 'package:app_news/viewTabs/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  MainMenu(this.signOut);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String fullname = '', email = '';
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fullname = pref.getString('fullname');
      email = pref.getString('email');
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(icon: Icon(Icons.lock_open), onPressed: () => signOut())
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            Home(),
            News(),
            Category(),
            Profile(),
          ],
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          // unselectedLabelStyle: ,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.new_releases),
              text: 'News',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Category',
            ),
            Tab(
              icon: Icon(Icons.perm_contact_calendar),
              text: 'Profile',
            )
          ],
        ),
      ),
    );
  }
}
