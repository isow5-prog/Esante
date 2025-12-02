/// Modèle représentant une mère dans le système eSanté
class MamanModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final String dateNaissance;
  final String profession;
  final int nombreEnfants;
  final String? qrCode;
  final String qrStatus;
  final int? healthCenterId;
  final String? healthCenterName;

  const MamanModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.dateNaissance,
    required this.profession,
    this.nombreEnfants = 0,
    this.qrCode,
    this.qrStatus = 'inactive',
    this.healthCenterId,
    this.healthCenterName,
  });

  String get nomComplet => '$prenom $nom';
  
  bool get isActive => qrStatus == 'active';

  factory MamanModel.fromJson(Map<String, dynamic> json) {
    return MamanModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['last_name'] ?? json['nom'] ?? '',
      prenom: json['first_name'] ?? json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['phone'] ?? json['telephone'] ?? '',
      adresse: json['address'] ?? json['adresse'] ?? '',
      dateNaissance: json['birth_date'] ?? json['dateNaissance'] ?? '',
      profession: json['profession'] ?? '',
      nombreEnfants: json['nombreEnfants'] is int
          ? json['nombreEnfants'] as int
          : int.tryParse(json['nombreEnfants']?.toString() ?? '0') ?? 0,
      qrCode: json['qr_code'],
      qrStatus: json['qr_status'] ?? 'inactive',
      healthCenterId: json['health_center_id'],
      healthCenterName: json['health_center_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': nom,
      'first_name': prenom,
      'email': email,
      'phone': telephone,
      'address': adresse,
      'birth_date': dateNaissance,
      'profession': profession,
      'nombreEnfants': nombreEnfants,
      'qr_code': qrCode,
      'qr_status': qrStatus,
      'health_center_id': healthCenterId,
      'health_center_name': healthCenterName,
    };
  }

  MamanModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? adresse,
    String? dateNaissance,
    String? profession,
    int? nombreEnfants,
    String? qrCode,
    String? qrStatus,
    int? healthCenterId,
    String? healthCenterName,
  }) {
    return MamanModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      profession: profession ?? this.profession,
      nombreEnfants: nombreEnfants ?? this.nombreEnfants,
      qrCode: qrCode ?? this.qrCode,
      qrStatus: qrStatus ?? this.qrStatus,
      healthCenterId: healthCenterId ?? this.healthCenterId,
      healthCenterName: healthCenterName ?? this.healthCenterName,
    );
  }
}
