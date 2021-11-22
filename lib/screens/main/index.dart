import 'package:flutter/material.dart';
import 'package:rentalz_flutter/screens/main/search/search_screen.dart';
import 'package:rentalz_flutter/screens/main/home/home_page.dart';
import 'package:rentalz_flutter/screens/main/host/host_page.dart';
import 'package:rentalz_flutter/screens/main/profile/profile_page.dart';
import 'package:rentalz_flutter/screens/property/wishlists.dart';

// import 'package:animations/animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchScreen(),
    HostPage(),
    WishlistsPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // appBar: AppBar(title: const Text("Home")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0),
          child: Center(
              child: ListView(
            children: [
              _widgetOptions.elementAt(_selectedIndex),
            ],
          )),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.grey.shade900,
          unselectedItemColor: Colors.grey.shade900.withOpacity(.30),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home_outlined),
            ),
            // BottomNavigationBarItem(
            //   label: "Wishlists",
            //   icon: Icon(Icons.favorite_border_outlined),
            // ),
            BottomNavigationBarItem(
              label: "Explore",
              icon: Icon(Icons.search_outlined),
            ),
            BottomNavigationBarItem(
              label: "Host",
              icon: Icon(Icons.add_circle_outline_outlined),
            ),
            BottomNavigationBarItem(
              label: "Wishlists",
              icon: Icon(Icons.favorite_outline),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
