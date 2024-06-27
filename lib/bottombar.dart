import 'package:bottomnavigationbar/airplaypage.dart';
import 'package:bottomnavigationbar/emailpage.dart';
import 'package:bottomnavigationbar/homepage.dart';
import 'package:bottomnavigationbar/pagespage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatefulWidget {

  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();

}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {

  List<Widget> pages = <Widget>[];
  Color _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;

  @override
  void initState() {
    pages
      ..add(HomePageScreen())
      ..add(RecommendedVideosScreen())
      ..add(PagesPageScreen())
      ..add(AirPlayPageScreen());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _bottomNavigationColor,
            ),
            label: "主页"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.email,
              color: _bottomNavigationColor,
            ),
            label: "推荐",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pages,
              color: _bottomNavigationColor,
            ),
            label: "历史",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.airplay,
              color: _bottomNavigationColor,
            ),
            label: "个人",
          )
        ],

        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: _bottomNavigationColor,
        unselectedItemColor: Colors.black,
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: pages[_currentIndex],
    );
  }
}