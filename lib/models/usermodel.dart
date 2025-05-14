class UserModel {
  final String nom;
  final String prenom;
  final String id;
  final String mdp;
  final String qrCode;
  final String avatarPath;

  UserModel({
    required this.nom,
    required this.prenom,
    required this.id,
    required this.mdp,
    required this.qrCode,
    required this.avatarPath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      id: json['id'] ?? '',
      mdp: json['mdp'] ?? '',
      qrCode: json['qr_code'] ?? '',
      avatarPath: json['avatar'] ?? '',
    );
  }
}
