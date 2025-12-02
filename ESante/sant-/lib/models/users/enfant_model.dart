class EnfantModel {
  final String id;
  final String nom;
  final String prenom;
  final String sexe;
  final String dateNaissance;
  final String numeroDossier;

  const EnfantModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.dateNaissance,
    required this.numeroDossier,
  });

  String get nomComplet => '$prenom $nom';

  factory EnfantModel.fromJson(Map<String, dynamic> json) {
    return EnfantModel(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      sexe: json['sexe'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
      numeroDossier: json['numeroDossier'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'dateNaissance': dateNaissance,
      'numeroDossier': numeroDossier,
    };
  }

  EnfantModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? sexe,
    String? dateNaissance,
    String? numeroDossier,
  }) {
    return EnfantModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      numeroDossier: numeroDossier ?? this.numeroDossier,
    );
  }
}


