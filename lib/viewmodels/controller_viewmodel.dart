import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usermodel.dart';

class ControllerViewModel extends ChangeNotifier {
  String? qrCodeData;

  // Méthode pour créer un utilisateur aveugle
  Future<void> createBlindUser({
    required String nom,
    required String prenom,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    try {
      final response =
          await supabase.from('utilisateurs_aveugles').insert({
            'nom': nom,
            'prenom': prenom,
            'controller_id': user.id,
          }).select();

      if (response.isNotEmpty) {
        final data = response.first;
        qrCodeData = "${data['nom']} ${data['prenom']}";
        notifyListeners(); 
      } else {
        print("Erreur lors de l'ajout de l'utilisateur aveugle !");
      }
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur aveugle : $e");
    }
  }

  // Liste des utilisateurs aveugles
  List<UserModel> blindUsers = [];

  // Méthode pour récupérer les utilisateurs aveugles
  Future<void> fetchBlindUsers() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    try {
      final response = await supabase
          .from('utilisateurs_aveugles')
          .select()
          .eq('controller_id', user.id); // Filtrer par controller_id

      if (response.isNotEmpty) {
        blindUsers = List<UserModel>.from(
          response.map((data) => UserModel.fromJson(data)),
        );
        notifyListeners(); // Notifie les widgets écoutant ce modèle
      } else {
        print("Aucun utilisateur aveugle trouvé !");
      }
    } catch (e) {
      print("Erreur de récupération des utilisateurs aveugles : $e");
    }
  }
}
