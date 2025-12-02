class PapaModel {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String adresse;
  final String dateNaissance;

  const PapaModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    required this.dateNaissance,
  });

  String get nomComplet => '$prenom $nom';

  factory PapaModel.fromJson(Map<String, dynamic> json) {
    return PapaModel(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
    };
  }

  PapaModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? adresse,
    String? dateNaissance,
  }) {
    return PapaModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dateNaissance: dateNaissance ?? this.dateNaissance,
    );
  }
}


