import 'package:flutter/material.dart';
import '../models/usermodel.dart';
import 'OpenStreetMap_page.dart';
import 'call_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _selectedIndex = 1; // Position sélectionnée par défaut

  static List<Widget> _widgetOptions(UserModel user) => [
    Container(), // Appel ne s'affiche jamais ici car on navigue directement
    OpenstreetmapPage(trackedUserId: user.id),
    Center(child: Text("Autres informations sur ${user.nom}")),
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
        items: const <BottomNavigationBarItem>[
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
