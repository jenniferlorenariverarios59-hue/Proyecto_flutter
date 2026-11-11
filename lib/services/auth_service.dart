import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Servicio de autenticación y persistencia real de usuarios para Glam Studio.
/// Funciona en Android y Flutter Web:
/// 1. Sincroniza con POST /api/auth/login y POST /api/auth/register cuando el servidor Node.js está activo.
/// 2. Persiste la base de datos de usuarios registrados y la sesión activa en SharedPreferences.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    initialize();
  }

  static const String _storageKeyUsersList = 'glam_studio_registered_users_v2';
  static const String _storageKeyActiveUser = 'glam_studio_active_user_v2';

  final ApiService _api = ApiService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  static const List<UserModel> _seedUsers = [
    UserModel(
      id: 'usr-admin-01',
      name: 'Sofía Laurent',
      email: 'admin@glamstudio.com',
      password: 'admin123',
      role: 'Administradora',
      phone: '+57 300 456 7890',
      city: 'Bogotá',
      skinType: 'Mixta',
      createdAt: '2026-10-01',
    ),
    UserModel(
      id: 'usr-client-01',
      name: 'Camila Restrepo',
      email: 'camila@correo.com',
      password: 'glam2026',
      role: 'Cliente VIP',
      phone: '+57 312 987 6543',
      city: 'Medellín',
      skinType: 'Normal',
      createdAt: '2026-10-15',
    ),
  ];

  List<UserModel> _registeredUsers = List.from(_seedUsers);
  List<UserModel> get registeredUsers => List.unmodifiable(_registeredUsers);

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar lista de usuarios registrados localmente
      final rawUsers = prefs.getString(_storageKeyUsersList);
      if (rawUsers != null && rawUsers.isNotEmpty) {
        final decoded = jsonDecode(rawUsers) as List<dynamic>;
        final parsed = decoded
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (parsed.isNotEmpty) {
          _registeredUsers = parsed;
        }
      } else {
        await _saveUsersToDisk();
      }

      // Cargar sesión activa si existe
      final rawActive = prefs.getString(_storageKeyActiveUser);
      if (rawActive != null && rawActive.isNotEmpty) {
        _currentUser = UserModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawActive)),
        );
      }
    } catch (_) {}
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveUsersToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_registeredUsers.map((u) => u.toJson()).toList());
      await prefs.setString(_storageKeyUsersList, encoded);
    } catch (_) {}
  }

  Future<void> _saveActiveSession(UserModel? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user == null) {
        await prefs.remove(_storageKeyActiveUser);
      } else {
        await prefs.setString(_storageKeyActiveUser, jsonEncode(user.toJson()));
      }
    } catch (_) {}
  }

  /// Inicia sesión verificando correo y contraseña contra la API REST y la base de datos persistente.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await initialize();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password;

    // 1. Intentar primero contra la API REST si está disponible
    final apiRes = await _api.loginUser(cleanEmail, cleanPass);
    if (apiRes.success && apiRes.data != null) {
      final loggedUser = apiRes.data!;
      final existingIdx = _registeredUsers
          .indexWhere((u) => u.email.toLowerCase() == cleanEmail);
      if (existingIdx >= 0) {
        _registeredUsers[existingIdx] = loggedUser;
      } else {
        _registeredUsers.add(loggedUser);
      }
      await _saveUsersToDisk();
      _currentUser = loggedUser;
      await _saveActiveSession(_currentUser);
      notifyListeners();
      return AuthResult(
        success: true,
        message: 'Bienvenida de nuevo, ${loggedUser.name} (API REST sincronizada).',
        user: loggedUser,
      );
    }

    // 2. Verificar en la base de datos persistente local
    final localMatch = _registeredUsers.where(
      (u) => u.email.toLowerCase() == cleanEmail && u.password == cleanPass,
    );

    if (localMatch.isNotEmpty) {
      _currentUser = localMatch.first;
      await _saveActiveSession(_currentUser);
      notifyListeners();
      return AuthResult(
        success: true,
        message: 'Bienvenida a Glam Studio, ${_currentUser!.name}.',
        user: _currentUser,
      );
    }

    final emailExists =
        _registeredUsers.any((u) => u.email.toLowerCase() == cleanEmail);
    if (emailExists) {
      return const AuthResult(
        success: false,
        message: 'Contraseña incorrecta. Verifica tus datos e intenta nuevamente.',
      );
    }

    return const AuthResult(
      success: false,
      message:
          'No encontramos una cuenta con ese correo. Puedes registrarte en la pestaña "Crear Cuenta".',
    );
  }

  /// Registra un nuevo usuario validando que el correo no esté duplicado y guardándolo persistentemente.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String skinType,
    String role = 'Cliente',
  }) async {
    await initialize();
    final cleanEmail = email.trim().toLowerCase();

    // Validar si ya existe localmente
    final alreadyExists =
        _registeredUsers.any((u) => u.email.toLowerCase() == cleanEmail);
    if (alreadyExists) {
      return const AuthResult(
        success: false,
        message: 'Este correo electrónico ya está registrado. Inicia sesión.',
      );
    }

    UserModel newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail,
      password: password,
      role: role,
      phone: phone.trim(),
      city: city.trim().isEmpty ? 'Bogotá' : city.trim(),
      skinType: skinType,
      createdAt: DateTime.now().toIso8601String().split('T').first,
    );

    // Sincronizar con la API REST si está en línea
    final apiRes = await _api.registerUser(newUser);
    if (apiRes.success && apiRes.data != null) {
      newUser = apiRes.data!;
    } else if (!apiRes.isOfflineFallback && apiRes.message != null) {
      return AuthResult(success: false, message: apiRes.message!);
    }

    _registeredUsers.add(newUser);
    await _saveUsersToDisk();

    _currentUser = newUser;
    await _saveActiveSession(_currentUser);
    notifyListeners();

    return AuthResult(
      success: true,
      message: '¡Cuenta creada con éxito! Bienvenida, ${newUser.name}.',
      user: newUser,
    );
  }

  /// Actualiza los datos del perfil del usuario activo
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String city,
    required String skinType,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      city: city.trim(),
      skinType: skinType,
    );
    _currentUser = updated;

    final idx = _registeredUsers.indexWhere((u) => u.id == updated.id);
    if (idx >= 0) {
      _registeredUsers[idx] = updated;
      await _saveUsersToDisk();
    }
    await _saveActiveSession(_currentUser);
    notifyListeners();
  }

  /// Cierra la sesión activa y regresa a la pantalla de inicio de sesión
  Future<void> logout() async {
    _currentUser = null;
    await _saveActiveSession(null);
    notifyListeners();
  }
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
