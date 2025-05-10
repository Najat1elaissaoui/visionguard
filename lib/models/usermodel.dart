class UserModel {
  final String nom;
  final String prenom;
  final String id;

  UserModel({required this.nom, required this.prenom, required this.id});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      id: json['id'] as String,
    );
  }
}
