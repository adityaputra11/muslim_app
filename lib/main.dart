import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:circle_bottom_navigation/widgets/tab_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muslim_app/view/compass.dart';
import 'package:muslim_app/view/home.Dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;
  List<Widget> _widgetOptions = [
    Text(
      'Al-Quran',
    ),
    MyHomePage(),
    MyCompass(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Muslim App"),
          elevation: 0.0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.map),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CircleBottomNavigation(
          initialSelection: _selectedIndex,
          tabs: [
            TabData(icon: Icons.book, title: 'Al-Quran'),
            TabData(icon: Icons.home, title: 'Home'),
            TabData(icon: Icons.location_city, title: 'Mesjid'),
          ],
          onTabChangedListener: (index) =>
              setState(() => _selectedIndex = index)),
    );
  }
}
