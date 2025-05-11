// repositories/blind_user_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionguard/models/usermodel.dart';

class BlindUserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addBlindUser(UserModel user) async {
    final userAuth = _client.auth.currentUser;

    if (userAuth == null) {
      throw Exception("Utilisateur non connecté");
    }

    await _client.from('utilisateurs_aveugles').insert({
      'nom': user.nom,
      'prenom': user.prenom,
       'mdp':user.mdp,
       'qr_code':user.qrCode,
      'controller_id': userAuth.id,
    });
  }

 Future<UserModel?> getUserBlind(String id) async {
  final response = await _client
      .from('utilisateurs_aveugles')
      .select()
      .eq('id', id)
      .single();

  return UserModel(
    nom: response['nom'],
    prenom: response['prenom'],
    id: response['id'],
      mdp: response['mdp'],
      qrCode: response['qr_code'],
    
  );
}

  
}
