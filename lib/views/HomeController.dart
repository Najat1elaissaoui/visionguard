import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionguard/viewmodels/controller_viewmodel.dart';
import 'package:visionguard/views/auth/login.dart';
import 'package:visionguard/views/controller_page.dart';
import 'package:visionguard/views/UserDetailScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class Homecontroller extends StatefulWidget {
  const Homecontroller({super.key});

  @override
  State<Homecontroller> createState() => _HomecontrollerState();
}

class _HomecontrollerState extends State<Homecontroller> {
  late ControllerViewModel controllerViewModel;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controllerViewModel = ControllerViewModel();
    controllerViewModel.fetchBlindUsers();
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return Consumer<ControllerViewModel>(
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Attention', style: TextStyle(color: Colors.red)),
                          content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
                          actions: [
                            TextButton(
                              child: Text('Non'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            ElevatedButton(
                            
                              child: Text('Oui'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controllerViewModel.deleteUser(user.id);
                        controllerViewModel.fetchBlindUsers();
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'Settings',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControllerPage()),
                );
                controllerViewModel.fetchBlindUsers();
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: ()async {
                final supabase=Supabase.instance.client;
                await supabase.auth.signOut();
                 Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
                // Logique de déconnexion ici
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
