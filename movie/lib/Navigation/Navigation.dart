import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Profile/Profile.dart';
import 'package:movie_app/Screens/Favorite/Favorite.dart';
import 'package:movie_app/Screens/Home/HomePage.dart';
import 'package:movie_app/Screens/Search/Search.dart';
import 'package:movie_app/Screens/SwipableCards/SwipableCards.dart';
import 'package:vibration/vibration.dart';

class MyHomePage extends StatefulWidget {
  final List<Page> _pages = [
    Page('Home', Icons.home, 30),
    Page('Search', Icons.search, 30),
    Page('Favorite', Icons.favorite, 30),
    Page('Suggest', Icons.assistant, 30),
    Page('Profile', Icons.person_outline, 30),
  ];

  final userid;
  final username;
  MyHomePage({Key? key, @required this.userid, this.username})
    : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;
  final GlobalKey<FavoriteState> _favoriteKey = GlobalKey<FavoriteState>();

  Future<void> _openPage(int index) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50); // Rung nhẹ khi chọn
    }
    setState(() {
      _currentPageIndex = index;
      if (index == 2 && _favoriteKey.currentState != null) {
        _favoriteKey.currentState!.reloadData();
      }
    });
  }

  void initState() {
    super.initState();
    Future(() {
      // Call your function
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _currentPageIndex = 0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List routes = [
      HomePage(),
      Search(),
      Favorite(key: _favoriteKey),
      SwipableCards(),
      Profile(),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: IndexedStack(
          index: _currentPageIndex,
          children: [
            HomePage(),
            Search(),
            Favorite(key: _favoriteKey),
            SwipableCards(),
            Profile(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: HexColor("#272727"),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _currentPageIndex,
        items:
            widget._pages
                .map(
                  (Page page) => BottomNavigationBarItem(
                    icon: Icon(page.iconData, size: page.size),
                    label: page.title,
                  ),
                )
                .toList(),
        onTap: _openPage,
      ),
    );
  }
}

class Page {
  final String title;
  final IconData iconData;
  final double size;
  Page(this.title, this.iconData, this.size);
}
