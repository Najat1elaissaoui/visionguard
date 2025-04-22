import 'package:flutter/material.dart';
import '../models/usermodel.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.nom} ${user.prenom}"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.chat),
            title: Text("Chat"),
            subtitle: Text("Discussion avec ${user.nom}"),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Position"),
            subtitle: Text("Position actuelle : ..."), // à remplacer par user.position si tu l’as
          ),
          // Tu peux ajouter d'autres infos ici
        ],
      ),
    );
  }
}
