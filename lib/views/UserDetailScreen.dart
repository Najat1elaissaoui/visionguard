import 'package:flutter/material.dart';
import '../models/usermodel.dart';
import 'OpenStreetMap_page.dart';
import 'call_screen.dart';
import 'package:visionguard/views/InformationsPage.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _selectedIndex = 1; // Par défaut, l’onglet Position est sélectionné

  static List<Widget> _widgetOptions(UserModel user) => [
    Container(), // L'appel est déclenché par navigation, pas ici
    OpenstreetmapPage(trackedUserId: user.id), // Carte réelle
    InformationsPage(user: user), // Affichage des infos utilisateur
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.nom} ${widget.user.prenom}"),
      ),
      body: _widgetOptions(widget.user)[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Appel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Position',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Infos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
