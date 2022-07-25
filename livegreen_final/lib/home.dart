import 'package:flutter/material.dart';
import 'package:livegreen_final/post_or_event.dart';
import 'package:livegreen_final/publish_event.dart';
import 'package:livegreen_final/ranking.dart';
import 'package:livegreen_final/screens/home_screen.dart';
import 'package:livegreen_final/search.dart';
import 'package:livegreen_final/events.dart';
import 'package:livegreen_final/publish_post.dart';

class HomePage extends StatefulWidget {
  final int index;
  HomePage({Key? key, required this.index}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _screens = [
    HomeScreen(),
    Search(),
    TypeSelector(),
    Events(),
    Ranking(),
  ];
  int _currentIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
    _currentIndex = widget.index;
    PageController _pageController = PageController(initialPage: widget.index);

    //_pageController.jumpToPage(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    /*        _currentIndex = widget.index;
    _pageController.jumpToPage(widget.index) */
    PageController _pageController = PageController(initialPage: widget.index);

    return Scaffold(
        body: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          physics: ScrollPhysics(),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.green,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.black,
              textTheme: Theme.of(context).textTheme),
          child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,
              selectedFontSize: 0,
              //backgroundColor: Colors.black,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: "Search"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle), label: " "),
                BottomNavigationBarItem(
                    icon: Icon(Icons.event_note), label: " "),
                BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events), label: " "),
              ]),
        ));
  }
}
