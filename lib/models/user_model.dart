/// Modelo de Usuario para autenticación real y persistencia en Glam Studio.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String city;
  final String skinType;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    this.role = 'Cliente',
    this.phone = '',
    this.city = 'Bogotá',
    this.skinType = 'Mixta',
    this.createdAt = '2026-11-01',
  });

  bool get isAdmin =>
      role.toLowerCase().contains('admin') ||
      email.toLowerCase() == 'admin@glamstudio.com';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'GS';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? city,
    String? skinType,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      skinType: skinType ?? this.skinType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? 'usr-${DateTime.now().millisecondsSinceEpoch}').toString(),
      name: (json['name'] ?? json['nombre'] ?? 'Usuaria Glam').toString(),
      email: (json['email'] ?? json['correo'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      role: (json['role'] ?? 'Cliente').toString(),
      phone: (json['phone'] ?? '').toString(),
      city: (json['city'] ?? 'Bogotá').toString(),
      skinType: (json['skinType'] ?? 'Mixta').toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'city': city,
        'skinType': skinType,
        'createdAt': createdAt,
      };
}
