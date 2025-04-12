import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionguard/viewmodels/controller_viewmodel.dart';

import 'package:visionguard/views/controller_page.dart';

class Homecontroller extends StatefulWidget {
  const Homecontroller({super.key});

  @override
  State<Homecontroller> createState() => _HomecontrollerState();
}

class _HomecontrollerState extends State<Homecontroller> {
  late ControllerViewModel controllerViewModel;

  @override
  void initState() {
    super.initState();
    controllerViewModel = ControllerViewModel();
    controllerViewModel.fetchBlindUsers(); // Récupère les utilisateurs aveugles
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => controllerViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Utilisateurs Aveugles'),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add),
              tooltip: 'Ajouter un utilisateur',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControllerPage()),
                );
              },
            ),
          ],
        ),
        body: Consumer<ControllerViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.blindUsers.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: viewModel.blindUsers.length,
              itemBuilder: (context, index) {
                final user = viewModel.blindUsers[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${user.nom} ${user.prenom}'),
                    subtitle: Text('ID: ${user.id}'),
                    trailing: Icon(Icons.accessibility),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
