import 'package:flutter/material.dart';
import 'package:spica/Structs/User.dart';
import 'package:spica/Views/Main/AccountView.dart';
import 'package:spica/Views/Main/FeedView.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:spica/Views/Main/MentionsView.dart';

class BottomNavigationController extends StatefulWidget {
  BottomNavigationController({Key key, @required this.signedinid}) : super(key: key);

  String signedinid;

  @override
  _BottomNavigationControllerState createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends State<BottomNavigationController> {
  int _currentIndex = 0;

  List<BottomNavigationItem> _children = [];

  @override
  void initState() {
    super.initState();
    _children = [
      BottomNavigationItem(widget: FeedView(), title: "Feed"),
      BottomNavigationItem(widget: MentionsView(), title: "Mentions"),
      BottomNavigationItem(
          widget: AccountView(user: User(id: widget.signedinid)),
          title: "Account")
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex].widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(
              icon: Icon(EvaIcons.atOutline), label: "Mentions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: "Account")
        ],
      ),
    );
  }
}

class BottomNavigationItem {
  Widget widget;
  String title;

  BottomNavigationItem({this.widget, this.title});
}
