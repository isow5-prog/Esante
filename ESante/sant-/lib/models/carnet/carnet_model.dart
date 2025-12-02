/// Modèle représentant un carnet de santé dans le système eSanté
class CarnetModel {
  final String id;
  final String title;
  final String lastUpdate;
  final String mamanId;
  final int numeroGrossesse;
  final String statut; // 'en_cours' ou 'termine'
  final String? identificationCode;
  final int? semaineGrossesse;
  final DateTime? dateDebutGrossesse;
  final DateTime? dateAccouchementPrevue;

  const CarnetModel({
    required this.id,
    required this.title,
    required this.lastUpdate,
    required this.mamanId,
    required this.numeroGrossesse,
    required this.statut,
    this.identificationCode,
    this.semaineGrossesse,
    this.dateDebutGrossesse,
    this.dateAccouchementPrevue,
  });

  bool get isEnCours => statut == 'en_cours';
  bool get isTermine => statut == 'termine';

  /// Calcule la semaine actuelle de grossesse
  int get semaineActuelle {
    if (semaineGrossesse != null) return semaineGrossesse!;
    if (dateDebutGrossesse == null) return 0;
    
    final now = DateTime.now();
    final diff = now.difference(dateDebutGrossesse!);
    return (diff.inDays / 7).floor();
  }

  /// Calcule le pourcentage de progression
  double get progression {
    final semaine = semaineActuelle;
    if (semaine <= 0) return 0;
    return (semaine / 40).clamp(0.0, 1.0);
  }

  /// Trimestre actuel
  int get trimestre {
    final semaine = semaineActuelle;
    if (semaine <= 13) return 1;
    if (semaine <= 26) return 2;
    return 3;
  }

  factory CarnetModel.fromJson(Map<String, dynamic> json) {
    return CarnetModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Carnet grossesse',
      lastUpdate: json['lastUpdate'] ?? json['last_update'] ?? '',
      mamanId: json['mamanId']?.toString() ?? json['mother_id']?.toString() ?? '',
      numeroGrossesse: json['numeroGrossesse'] is int
          ? json['numeroGrossesse'] as int
          : json['numero_grossesse'] is int
              ? json['numero_grossesse'] as int
              : int.tryParse(json['numeroGrossesse']?.toString() ?? 
                  json['numero_grossesse']?.toString() ?? '1') ?? 1,
      statut: json['statut'] ?? json['status'] ?? 'en_cours',
      identificationCode: json['identification_code'],
      semaineGrossesse: json['semaine_grossesse'],
      dateDebutGrossesse: json['date_debut_grossesse'] != null
          ? DateTime.tryParse(json['date_debut_grossesse'])
          : null,
      dateAccouchementPrevue: json['date_accouchement_prevue'] != null
          ? DateTime.tryParse(json['date_accouchement_prevue'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastUpdate': lastUpdate,
      'mamanId': mamanId,
      'numeroGrossesse': numeroGrossesse,
      'statut': statut,
      'identification_code': identificationCode,
      'semaine_grossesse': semaineGrossesse,
      'date_debut_grossesse': dateDebutGrossesse?.toIso8601String(),
      'date_accouchement_prevue': dateAccouchementPrevue?.toIso8601String(),
    };
  }

  CarnetModel copyWith({
    String? id,
    String? title,
    String? lastUpdate,
    String? mamanId,
    int? numeroGrossesse,
    String? statut,
    String? identificationCode,
    int? semaineGrossesse,
    DateTime? dateDebutGrossesse,
    DateTime? dateAccouchementPrevue,
  }) {
    return CarnetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      mamanId: mamanId ?? this.mamanId,
      numeroGrossesse: numeroGrossesse ?? this.numeroGrossesse,
      statut: statut ?? this.statut,
      identificationCode: identificationCode ?? this.identificationCode,
      semaineGrossesse: semaineGrossesse ?? this.semaineGrossesse,
      dateDebutGrossesse: dateDebutGrossesse ?? this.dateDebutGrossesse,
      dateAccouchementPrevue: dateAccouchementPrevue ?? this.dateAccouchementPrevue,
    );
  }
}
