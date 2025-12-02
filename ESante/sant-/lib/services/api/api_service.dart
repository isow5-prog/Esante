import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Configuration de l'API
class ApiConfig {
  // URL de base du backend Django
  // En développement : utiliser l'IP de la machine ou 10.0.2.2 pour l'émulateur Android
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Timeout pour les requêtes
  static const Duration timeout = Duration(seconds: 30);
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

/// Service principal pour les appels API
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;

  /// Headers par défaut pour les requêtes
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// Définir les tokens d'authentification
  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  /// Effacer les tokens (déconnexion)
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _accessToken != null;

  /// Obtenir le token d'accès
  String? get accessToken => _accessToken;

  /// Rafraîchir le token d'accès
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Requête GET
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _headers).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// Requête POST
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// Requête PATCH
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// Requête DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
      ).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: $e');
    }
  }

  /// Gérer la réponse HTTP
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (e) {
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    // Gérer les erreurs
    String message = 'Erreur inconnue';
    if (data is Map && data.containsKey('detail')) {
      message = data['detail'].toString();
    } else if (data is Map) {
      message = data.values.first.toString();
    }

    switch (statusCode) {
      case 400:
        throw ApiException('Requête invalide: $message', statusCode: 400, data: data);
      case 401:
        throw ApiException('Non autorisé: $message', statusCode: 401, data: data);
      case 403:
        throw ApiException('Accès refusé: $message', statusCode: 403, data: data);
      case 404:
        throw ApiException('Ressource non trouvée: $message', statusCode: 404, data: data);
      case 500:
        throw ApiException('Erreur serveur: $message', statusCode: 500, data: data);
      default:
        throw ApiException(message, statusCode: statusCode, data: data);
    }
  }
}

