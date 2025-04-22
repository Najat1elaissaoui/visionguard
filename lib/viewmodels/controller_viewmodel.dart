import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usermodel.dart';

class ControllerViewModel extends ChangeNotifier {
  String? qrCodeData;
  List<UserModel> blindUsers = [];

  final supabase = Supabase.instance.client;

  Future<void> createBlindUser({
    required String nom,
    required String prenom,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    try {
      final response = await supabase.from('utilisateurs_aveugles').insert({
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

  Future<void> fetchBlindUsers() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    try {
      final response = await supabase
          .from('utilisateurs_aveugles')
          .select()
          .eq('controller_id', user.id);

      if (response.isNotEmpty) {
        blindUsers = List<UserModel>.from(
          response.map((data) => UserModel.fromJson(data)),
        );
        notifyListeners();
      } else {
        blindUsers = [];
        notifyListeners();
        print("Aucun utilisateur aveugle trouvé !");
      }
    } catch (e) {
      print("Erreur de récupération des utilisateurs aveugles : $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await supabase.from('utilisateurs_aveugles').delete().eq('id', userId);
      print("Utilisateur supprimé avec succès !");
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }
}
