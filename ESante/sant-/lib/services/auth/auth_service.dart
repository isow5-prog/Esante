import 'dart:convert';
import 'package:esante/services/api/api_service.dart';
import 'package:esante/models/users/maman_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Modèle pour les données utilisateur après connexion
class AuthUser {
  final int id;
  final String qrCode;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String birthDate;
  final String profession;
  final bool hasRecord;

  AuthUser({
    required this.id,
    required this.qrCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.profession,
    required this.hasRecord,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      qrCode: json['qr_code'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthDate: json['birth_date'] ?? '',
      profession: json['profession'] ?? '',
      hasRecord: json['has_record'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'qr_code': qrCode,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'birth_date': birthDate,
    'profession': profession,
    'has_record': hasRecord,
  };
}

/// Service d'authentification pour les mamans
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  AuthUser? _currentUser;

  /// Utilisateur actuellement connecté
  AuthUser? get currentUser => _currentUser;

  /// Vérifier si connecté
  bool get isLoggedIn => _api.isAuthenticated && _currentUser != null;

  /// Connexion avec le code QR
  /// 
  /// La maman scanne son QR code pour se connecter.
  /// Le backend vérifie que le code existe et retourne les infos de la mère.
  Future<AuthUser> loginWithQRCode(String qrCode) async {
    try {
      final response = await _api.post('/mothers/login/', body: {
        'qr_code': qrCode,
      });

      // Sauvegarder les tokens
      if (response['access'] != null && response['refresh'] != null) {
        _api.setTokens(
          access: response['access'],
          refresh: response['refresh'],
        );
      }

      // Créer l'utilisateur
      _currentUser = AuthUser.fromJson(response['mother']);
      
      // Sauvegarder localement
      await _saveAuthData(response);

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  /// Connexion avec email et mot de passe (alternative)
  Future<AuthUser> loginWithCredentials(String email, String password) async {
    try {
      final response = await _api.post('/mothers/login-email/', body: {
        'email': email,
        'password': password,
      });

      // Sauvegarder les tokens
      if (response['access'] != null && response['refresh'] != null) {
        _api.setTokens(
          access: response['access'],
          refresh: response['refresh'],
        );
      }

      // Créer l'utilisateur
      _currentUser = AuthUser.fromJson(response['mother']);
      
      // Sauvegarder localement
      await _saveAuthData(response);

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer le profil de l'utilisateur connecté
  Future<AuthUser> getProfile() async {
    try {
      final response = await _api.get('/mothers/me/');
      _currentUser = AuthUser.fromJson(response);
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _api.clearTokens();
    _currentUser = null;
    await _clearAuthData();
  }

  /// Vérifier et restaurer la session
  Future<bool> checkSession() async {
    try {
      final authData = await _loadAuthData();
      if (authData == null) return false;

      _api.setTokens(
        access: authData['access'],
        refresh: authData['refresh'],
      );

      // Essayer de récupérer le profil
      await getProfile();
      return true;
    } catch (e) {
      // Token expiré, essayer de rafraîchir
      final refreshed = await _api.refreshAccessToken();
      if (refreshed) {
        try {
          await getProfile();
          return true;
        } catch (e) {
          await logout();
          return false;
        }
      }
      await logout();
      return false;
    }
  }

  /// Sauvegarder les données d'authentification localement
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/auth.json');
      await file.writeAsString(jsonEncode({
        'access': data['access'],
        'refresh': data['refresh'],
        'mother': data['mother'],
      }));
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  /// Charger les données d'authentification
  Future<Map<String, dynamic>?> _loadAuthData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/auth.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      // Ignorer les erreurs de chargement
    }
    return null;
  }

  /// Effacer les données d'authentification
  Future<void> _clearAuthData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/auth.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignorer les erreurs
    }
  }
}

