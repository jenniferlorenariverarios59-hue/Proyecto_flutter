import 'package:flutter/material.dart';

/// Representa un tono o variante de color cosmético (labial, base, sombra, etc.).
class ProductShade {
  final String name;
  final String hex;

  const ProductShade({
    required this.name,
    required this.hex,
  });

  Color get color {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFC86D7A);
  }

  factory ProductShade.fromJson(Map<String, dynamic> json) {
    return ProductShade(
      name: (json['name'] ?? json['nombre'] ?? 'Tono Clásico').toString(),
      hex: (json['hex'] ?? '#C86D7A').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'hex': hex,
      };
}

/// Modelo de datos representativo de un Producto de Maquillaje y Belleza en Glam Studio.
/// Conserva la compatibilidad con el modelo original de TechStore y añade atributos de cosmética.
class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String ingredients;
  final double price;
  final double? originalPrice;
  final int stock;
  final String category;
  final String sku;
  final String? imageUrl;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isBestSeller;
  final String finish;
  final String shadeName;
  final String shadeHex;
  final List<ProductShade> shades;

  /// Las 6 categorías oficiales solicitadas para la tienda de maquillaje.
  static const List<String> officialCategories = [
    'Labiales',
    'Bases y correctores',
    'Sombras',
    'Máscaras de pestañas',
    'Productos para el cuidado facial',
    'Accesorios de belleza',
  ];

  Product({
    required this.id,
    required this.name,
    this.brand = 'Glam Studio Paris',
    required this.description,
    this.ingredients = 'Vitamina E, Ácido Hialurónico, Extractos Botánicos y Pigmentos Minerales.',
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.category,
    required this.sku,
    this.imageUrl,
    this.rating = 4.9,
    this.reviewsCount = 48,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.finish = 'Acabado Profesional',
    this.shadeName = 'Rosa Empolvado',
    this.shadeHex = '#C86D7A',
    List<ProductShade>? shades,
  }) : shades = (shades != null && shades.isNotEmpty)
            ? shades
            : [ProductShade(name: shadeName, hex: shadeHex)];

  /// Indica si el producto tiene precio de oferta activo
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Precio formateado en USD
  String get formattedPrice => '\$${price.toStringAsFixed(2)} USD';

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  /// Color principal del tono seleccionado
  Color get primaryShadeColor {
    return shades.first.color;
  }

  /// Estado calculado de disponibilidad de inventario
  String get status {
    if (stock <= 0) return 'out-of-stock';
    if (stock <= 10) return 'low-stock';
    return 'in-stock';
  }

  /// Texto legible del estado en español
  String get statusText {
    switch (status) {
      case 'out-of-stock':
        return 'Agotado';
      case 'low-stock':
        return '$stock disp. (Últimas uds.)';
      default:
        return '$stock disponibles';
    }
  }

  /// Serialización desde mapa JSON recibido de la API REST o almacenamiento persistente
  factory Product.fromJson(Map<String, dynamic> json) {
    final String rawShadeName = (json['shadeName'] ?? 'Rosa Empolvado').toString();
    final String rawShadeHex = (json['shadeHex'] ?? '#C86D7A').toString();

    List<ProductShade> parsedShades = [];
    if (json['shades'] is List) {
      parsedShades = (json['shades'] as List)
          .whereType<Map>()
          .map((e) => ProductShade.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (parsedShades.isEmpty) {
      parsedShades = [ProductShade(name: rawShadeName, hex: rawShadeHex)];
    }

    return Product(
      id: (json['id'] ?? json['_id'] ?? 'prod-${DateTime.now().millisecondsSinceEpoch}').toString(),
      name: (json['name'] ?? json['nombre'] ?? 'Producto de Belleza').toString(),
      brand: (json['brand'] ?? json['marca'] ?? 'Glam Studio Paris').toString(),
      description: (json['description'] ?? json['descripcion'] ?? '').toString(),
      ingredients: (json['ingredients'] ??
              'Vitamina E, Ácido Hialurónico, Extractos Botánicos y Pigmentos Minerales.')
          .toString(),
      price: (json['price'] ?? json['precio'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      stock: (json['stock'] ?? json['cantidad'] ?? 15).toInt(),
      category: (json['category'] ?? json['categoria'] ?? 'Labiales').toString(),
      sku: (json['sku'] ?? 'SKU-GLM-${DateTime.now().millisecondsSinceEpoch % 10000}').toString(),
      imageUrl: (json['imageUrl'] ?? json['imagen'] ?? json['image_url'])?.toString(),
      rating: (json['rating'] ?? 4.8).toDouble(),
      reviewsCount: (json['reviewsCount'] ?? 42).toInt(),
      isFeatured: json['isFeatured'] == true,
      isBestSeller: json['isBestSeller'] == true,
      finish: (json['finish'] ?? 'Acabado Profesional').toString(),
      shadeName: parsedShades.first.name,
      shadeHex: parsedShades.first.hex,
      shades: parsedShades,
    );
  }

  /// Deserialización a mapa JSON para enviar en peticiones POST / PUT a la API y SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'ingredients': ingredients,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'category': category,
      'sku': sku,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'finish': finish,
      'shadeName': shadeName,
      'shadeHex': shadeHex,
      'shades': shades.map((s) => s.toJson()).toList(),
    };
  }

  /// Copia de objeto para modificaciones inmutables
  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    String? ingredients,
    double? price,
    double? originalPrice,
    bool clearOriginalPrice = false,
    int? stock,
    String? category,
    String? sku,
    String? imageUrl,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isBestSeller,
    String? finish,
    String? shadeName,
    String? shadeHex,
    List<ProductShade>? shades,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      price: price ?? this.price,
      originalPrice: clearOriginalPrice ? null : (originalPrice ?? this.originalPrice),
      stock: stock ?? this.stock,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      finish: finish ?? this.finish,
      shadeName: shadeName ?? this.shadeName,
      shadeHex: shadeHex ?? this.shadeHex,
      shades: shades ?? this.shades,
    );
  }
}
