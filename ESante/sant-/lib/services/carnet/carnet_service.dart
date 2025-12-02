import 'package:esante/services/api/api_service.dart';
import 'package:esante/models/carnet/carnet_model.dart';

/// Modèle pour les données détaillées du carnet de santé
class CarnetDetail {
  final int id;
  final String identificationCode;
  final String fatherName;
  final String fatherPhone;
  final String fatherProfession;
  final String pereCarnetCenter;
  final String birthCenter;
  final String allocationInfo;
  final DateTime createdAt;
  final MotherInfo mother;

  CarnetDetail({
    required this.id,
    required this.identificationCode,
    required this.fatherName,
    required this.fatherPhone,
    required this.fatherProfession,
    required this.pereCarnetCenter,
    required this.birthCenter,
    required this.allocationInfo,
    required this.createdAt,
    required this.mother,
  });

  factory CarnetDetail.fromJson(Map<String, dynamic> json) {
    return CarnetDetail(
      id: json['id'] ?? 0,
      identificationCode: json['identification_code'] ?? '',
      fatherName: json['father_name'] ?? '',
      fatherPhone: json['father_phone'] ?? '',
      fatherProfession: json['father_profession'] ?? '',
      pereCarnetCenter: json['pere_carnet_center'] ?? '',
      birthCenter: json['birth_center'] ?? '',
      allocationInfo: json['allocation_info'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      mother: MotherInfo.fromJson(json['mother'] ?? {}),
    );
  }
}

/// Informations de la mère
class MotherInfo {
  final int id;
  final String fullName;
  final String phone;
  final String address;
  final String birthDate;
  final String profession;
  final String? qrCode;
  final String qrStatus;

  MotherInfo({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.profession,
    this.qrCode,
    required this.qrStatus,
  });

  factory MotherInfo.fromJson(Map<String, dynamic> json) {
    return MotherInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthDate: json['birth_date'] ?? '',
      profession: json['profession'] ?? '',
      qrCode: json['qr_code'],
      qrStatus: json['qr_status'] ?? 'inactive',
    );
  }
}

/// Modèle pour les consultations prénatales
class ConsultationPrenatale {
  final int id;
  final DateTime date;
  final int semaineGrossesse;
  final double? poids;
  final String? tension;
  final double? tailleUterine;
  final String? rythmeCardiaque;
  final String? observations;
  final String agentSante;

  ConsultationPrenatale({
    required this.id,
    required this.date,
    required this.semaineGrossesse,
    this.poids,
    this.tension,
    this.tailleUterine,
    this.rythmeCardiaque,
    this.observations,
    required this.agentSante,
  });

  factory ConsultationPrenatale.fromJson(Map<String, dynamic> json) {
    return ConsultationPrenatale(
      id: json['id'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      semaineGrossesse: json['semaine_grossesse'] ?? 0,
      poids: json['poids']?.toDouble(),
      tension: json['tension'],
      tailleUterine: json['taille_uterine']?.toDouble(),
      rythmeCardiaque: json['rythme_cardiaque'],
      observations: json['observations'],
      agentSante: json['agent_sante'] ?? '',
    );
  }
}

/// Modèle pour les vaccinations
class Vaccination {
  final int id;
  final String nom;
  final DateTime date;
  final DateTime? dateRappel;
  final String statut;
  final String? observations;

  Vaccination({
    required this.id,
    required this.nom,
    required this.date,
    this.dateRappel,
    required this.statut,
    this.observations,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      dateRappel: json['date_rappel'] != null 
          ? DateTime.tryParse(json['date_rappel']) 
          : null,
      statut: json['statut'] ?? 'planifie',
      observations: json['observations'],
    );
  }
}

/// Modèle pour les rendez-vous
class RendezVous {
  final int id;
  final String type;
  final DateTime date;
  final String heure;
  final String lieu;
  final String? agentSante;
  final String statut;
  final String? notes;

  RendezVous({
    required this.id,
    required this.type,
    required this.date,
    required this.heure,
    required this.lieu,
    this.agentSante,
    required this.statut,
    this.notes,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      heure: json['heure'] ?? '',
      lieu: json['lieu'] ?? '',
      agentSante: json['agent_sante'],
      statut: json['statut'] ?? 'planifie',
      notes: json['notes'],
    );
  }
}

/// Service pour gérer les carnets de santé
class CarnetService {
  static final CarnetService _instance = CarnetService._internal();
  factory CarnetService() => _instance;
  CarnetService._internal();

  final ApiService _api = ApiService();

  /// Récupérer les carnets de la mère connectée
  Future<List<CarnetModel>> getMesCarnets() async {
    try {
      final response = await _api.get('/mothers/me/carnets/');
      final List<dynamic> data = response is List ? response : response['results'] ?? [];
      return data.map((json) => CarnetModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer le détail d'un carnet
  Future<CarnetDetail> getCarnetDetail(String carnetId) async {
    try {
      final response = await _api.get('/mothers/me/carnets/$carnetId/');
      return CarnetDetail.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les consultations prénatales
  Future<List<ConsultationPrenatale>> getConsultations(String carnetId) async {
    try {
      final response = await _api.get('/mothers/me/carnets/$carnetId/consultations/');
      final List<dynamic> data = response is List ? response : response['results'] ?? [];
      return data.map((json) => ConsultationPrenatale.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les vaccinations
  Future<List<Vaccination>> getVaccinations(String carnetId) async {
    try {
      final response = await _api.get('/mothers/me/carnets/$carnetId/vaccinations/');
      final List<dynamic> data = response is List ? response : response['results'] ?? [];
      return data.map((json) => Vaccination.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les prochains rendez-vous
  Future<List<RendezVous>> getRendezVous() async {
    try {
      final response = await _api.get('/mothers/me/rendez-vous/');
      final List<dynamic> data = response is List ? response : response['results'] ?? [];
      return data.map((json) => RendezVous.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer le prochain rendez-vous
  Future<RendezVous?> getProchainRendezVous() async {
    try {
      final response = await _api.get('/mothers/me/prochain-rdv/');
      if (response != null && response['id'] != null) {
        return RendezVous.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les statistiques de la mère
  Future<Map<String, dynamic>> getMesStats() async {
    try {
      final response = await _api.get('/mothers/me/stats/');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

