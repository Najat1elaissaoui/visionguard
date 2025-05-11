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
    required String mdp,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print("Aucun utilisateur connecté !");
      return;
    }

    try {
      // Génère le contenu du QR code
      final qrContent = "$nom $prenom $mdp";

      // Insertion dans la base avec retour des données insérées
      final response = await supabase
          .from('utilisateurs_aveugles')
          .insert({
            'nom': nom,
            'prenom': prenom,
            'mdp': mdp,
            'controller_id': user.id,
            'qr_code': qrContent,
          })
          .select('*'); // récupère les valeurs insérées

      if (response.isNotEmpty) {
        // On utilise la valeur réellement stockée dans Supabase
        qrCodeData = response[0]['qr_code'] as String?;
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
Future<bool> checkMdpExist(String mdp) async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("Aucun utilisateur connecté !");
    return false;
  }

  try {
    final response = await supabase
        .from('utilisateurs_aveugles')
        .select('mdp')
        .eq('mdp', mdp)
        .single();

    return response != null; // Si un résultat est trouvé, le mot de passe existe déjà
  } catch (e) {
    print("Erreur lors de la vérification du mot de passe : $e");
    return false;
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
