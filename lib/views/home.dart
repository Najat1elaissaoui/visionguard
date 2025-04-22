import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/controller_viewmodel.dart';
import '../models/usermodel.dart';
import 'package:visionguard/views/UserDetailScreen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    final viewModel = Provider.of<ControllerViewModel>(context, listen: false);
    viewModel.fetchBlindUsers();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ControllerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des utilisateurs"),
      ),
      body: ListView.builder(
        itemCount: viewModel.blindUsers.length,
        itemBuilder: (context, index) {
          final user = viewModel.blindUsers[index];
          return ListTile(
  title: Text("${user.nom} ${user.prenom}"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(user: user),
      ),
    );
  },
);

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/controller').then((_) {
            // 🔁 Actualise les données après retour de la page Controller
            _fetchUsers();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
