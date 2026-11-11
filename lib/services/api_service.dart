import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user_model.dart';

/// Resultado encapsulado de operaciones de red HTTP REST.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final bool isOfflineFallback;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.isOfflineFallback = false,
  });
}

/// Servicio encargado de la comunicación HTTP REST con la API backend de Glam Studio.
/// Soporta productos (GET, POST, PUT, DELETE) y autenticación de usuarios (Login / Registro).
class ApiService {
  /// URL base configurable para la API REST (Node.js Express en puerto 3000).
  static String baseUrl = 'http://localhost:3000/api';

  /// Endpoint alternativo para emulador de Android (10.0.2.2 apunta al host).
  static String androidEmulatorBaseUrl = 'http://10.0.2.2:3000/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Comprueba la conectividad hacia una URL y calcula la latencia en milisegundos.
  Future<Map<String, dynamic>> testConnection(String url) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(url);
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 3));
      stopwatch.stop();
      return {
        'success': response.statusCode >= 200 && response.statusCode < 400,
        'statusCode': response.statusCode,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message':
            'Servidor Glam Studio respondió HTTP ${response.statusCode} en ${stopwatch.elapsedMilliseconds} ms',
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'statusCode': 0,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message': 'Sin respuesta del servidor remoto (${e.runtimeType}). Usando persistencia local.',
      };
    }
  }

  /// Consulta el catálogo de productos mediante GET /products.
  Future<ApiResponse<List<Product>>> fetchProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/products');
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> list =
            decoded is List ? decoded : (decoded['data'] ?? []);
        final products = list
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        return ApiResponse(success: true, data: products);
      } else {
        return ApiResponse(
          success: false,
          message: 'Error en el servidor API (HTTP ${response.statusCode})',
        );
      }
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Tiempo de espera agotado ($baseUrl). Catálogo local persistente activo.',
        isOfflineFallback: true,
      );
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Operando con base de datos local persistente (Servidor API apagado).',
        isOfflineFallback: true,
      );
    }
  }

  /// Registra un nuevo producto mediante POST /products.
  Future<ApiResponse<Product>> createProduct(Product product) async {
    try {
      final uri = Uri.parse('$baseUrl/products');
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(product.toJson()),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final created = Product.fromJson(
          decoded is Map<String, dynamic> ? decoded : product.toJson(),
        );
        return ApiResponse(
          success: true,
          data: created,
          message: 'Producto guardado en la API REST y base de datos local.',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'El servidor rechazó el producto (HTTP ${response.statusCode})',
        );
      }
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Guardado en almacenamiento persistente local.',
        isOfflineFallback: true,
      );
    }
  }

  /// Actualiza un producto existente mediante PUT /products/{id}.
  Future<ApiResponse<Product>> updateProduct(Product product) async {
    try {
      final uri = Uri.parse('$baseUrl/products/${product.id}');
      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(product.toJson()),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: Product.fromJson(
            decoded is Map<String, dynamic> ? decoded : product.toJson(),
          ),
        );
      }
      return ApiResponse(success: false, isOfflineFallback: true);
    } catch (_) {
      return ApiResponse(success: false, isOfflineFallback: true);
    }
  }

  /// Elimina un producto mediante DELETE /products/{id}.
  Future<ApiResponse<bool>> deleteProduct(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$id');
      final response = await _client
          .delete(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 3));

      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
      );
    } catch (_) {
      return ApiResponse(success: false, isOfflineFallback: true);
    }
  }

  /// Inicia sesión contra POST /auth/login de la API REST si está activa.
  Future<ApiResponse<UserModel>> loginUser(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 3));

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userMap = Map<String, dynamic>.from(decoded['user'] ?? decoded);
        return ApiResponse(
          success: true,
          data: UserModel.fromJson({...userMap, 'password': password}),
        );
      } else {
        return ApiResponse(
          success: false,
          message: decoded['error']?.toString() ?? 'Credenciales incorrectas.',
          isOfflineFallback: false,
        );
      }
    } catch (_) {
      return ApiResponse(
        success: false,
        isOfflineFallback: true,
      );
    }
  }

  /// Registra un usuario en POST /auth/register de la API REST si está activa.
  Future<ApiResponse<UserModel>> registerUser(UserModel newUser) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(newUser.toJson()),
          )
          .timeout(const Duration(seconds: 3));

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userMap = Map<String, dynamic>.from(decoded['user'] ?? decoded);
        return ApiResponse(
          success: true,
          data: UserModel.fromJson({...userMap, 'password': newUser.password}),
        );
      } else {
        return ApiResponse(
          success: false,
          message: decoded['error']?.toString() ?? 'No se pudo registrar el usuario.',
          isOfflineFallback: false,
        );
      }
    } catch (_) {
      return ApiResponse(
        success: false,
        isOfflineFallback: true,
      );
    }
  }
}
