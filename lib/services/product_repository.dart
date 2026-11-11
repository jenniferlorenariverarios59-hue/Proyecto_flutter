import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'api_service.dart';

/// Repositorio central que administra el catálogo de Glam Studio con patrón ChangeNotifier
/// y almacenamiento persistente en disco (SharedPreferences) + sincronización con API REST.
class ProductRepository extends ChangeNotifier {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository({ApiService? apiService}) {
    if (apiService != null) {
      _instance._apiService = apiService;
    }
    return _instance;
  }
  ProductRepository._internal() : _apiService = ApiService() {
    _initializePersistence();
  }

  static const String _storageKeyProducts = 'glam_studio_persistent_products_v2';
  static const String _storageKeyFavorites = 'glam_studio_favorite_ids_v2';

  ApiService _apiService;
  bool _initialized = false;

  bool _isApiOnline = false;
  bool get isApiOnline => _isApiOnline;

  bool _forcedLocalMode = false;
  bool get forcedLocalMode => _forcedLocalMode;
  set forcedLocalMode(bool val) {
    _forcedLocalMode = val;
    notifyListeners();
  }

  /// Getters y métodos de compatibilidad para modo offline
  bool get offlineMode => _forcedLocalMode;
  void setOfflineMode(bool val) {
    forcedLocalMode = val;
  }

  String _statusMessage = 'Inicializando catálogo de belleza...';
  String get statusMessage => _statusMessage;

  final List<String> _favoriteIds = ['prod-101', 'prod-201', 'prod-301'];
  List<String> get favoriteIds => List.unmodifiable(_favoriteIds);

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKeyFavorites, _favoriteIds);
    } catch (_) {}
  }

  /// Catálogo base real de maquillaje y productos de belleza en las 6 categorías oficiales
  static final List<Product> _seedProducts = [
    // 1. LABIALES
    Product(
      id: 'prod-101',
      name: 'Labial Líquido Velvet Matte Couture',
      brand: 'Glam Studio Paris',
      category: 'Labiales',
      price: 24.50,
      originalPrice: 29.00,
      stock: 32,
      sku: 'SKU-LAB-101',
      rating: 4.9,
      reviewsCount: 148,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Mate Aterciopelado',
      shadeName: 'Rosa Empolvado',
      shadeHex: '#C86D7A',
      shades: const [
        ProductShade(name: 'Rosa Empolvado', hex: '#C86D7A'),
        ProductShade(name: 'Vino Imperial', hex: '#6B1D2F'),
        ProductShade(name: 'Rojo Rubí', hex: '#B81D24'),
        ProductShade(name: 'Nude Almendra', hex: '#B67E6F'),
      ],
      description:
          'Labial líquido de alta pigmentación y acabado mate aterciopelado enriquecido con ácido hialurónico y vitamina E. Hasta 12 horas de duración sin resecar ni transferir.',
      ingredients:
          'Isododecane, Dimethicone, Tocopheryl Acetate (Vitamina E), Sodium Hyaluronate, Pigmentos Minerales.',
      imageUrl:
          'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-102',
      name: 'Aceite Labial Silk Glow Lip Oil Tint',
      brand: 'Lumière Beauté',
      category: 'Labiales',
      price: 21.00,
      originalPrice: 25.00,
      stock: 28,
      sku: 'SKU-LAB-102',
      rating: 4.8,
      reviewsCount: 96,
      isFeatured: true,
      isBestSeller: false,
      finish: 'Brillo Espejo Hidratante',
      shadeName: 'Cereza Cristal',
      shadeHex: '#D9385A',
      shades: const [
        ProductShade(name: 'Cereza Cristal', hex: '#D9385A'),
        ProductShade(name: 'Pétalo Rosado', hex: '#E68A9E'),
        ProductShade(name: 'Coral Melocotón', hex: '#E87A64'),
      ],
      description:
          'Aceite labial ultraligero con efecto espejo y tinte adaptable al pH. Nutre profundamente con aceite de jojoba orgánico y extracto de cereza dulce.',
      ingredients:
          'Simmondsia Chinensis (Jojoba) Seed Oil, Prunus Avium Seed Oil, Squalane, Tocopherol.',
      imageUrl:
          'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-103',
      name: 'Barra de Labios Satin Couture',
      brand: 'Maison Rose',
      category: 'Labiales',
      price: 26.00,
      stock: 19,
      sku: 'SKU-LAB-103',
      rating: 4.7,
      reviewsCount: 74,
      isFeatured: false,
      isBestSeller: true,
      finish: 'Satinado Cremoso',
      shadeName: 'Nude Cashmere',
      shadeHex: '#C28275',
      shades: const [
        ProductShade(name: 'Nude Cashmere', hex: '#C28275'),
        ProductShade(name: 'Rosa Parisiense', hex: '#C95B72'),
        ProductShade(name: 'Borgoña Chic', hex: '#5E1929'),
      ],
      description:
          'Labial en barra con acabado satinado luminoso y manteca de karité orgánica. Aporta volumen óptico y confort durante todo el día.',
      ingredients:
          'Ricinus Communis Seed Oil, Candelilla Cera, Butyrospermum Parkii Butter, Ceramide NP.',
      imageUrl:
          'https://images.unsplash.com/photo-1591360236480-4ed861025fa1?w=700&auto=format&fit=crop&q=80',
    ),

    // 2. BASES Y CORRECTORES
    Product(
      id: 'prod-201',
      name: 'Base Sérum Luminosa Silk Skin SPF 30',
      brand: 'Glam Studio Paris',
      category: 'Bases y correctores',
      price: 38.00,
      originalPrice: 44.00,
      stock: 24,
      sku: 'SKU-BAS-201',
      rating: 4.9,
      reviewsCount: 210,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Luminoso Natural (Segunda Piel)',
      shadeName: '210 Beige Neutro',
      shadeHex: '#E0B596',
      shades: const [
        ProductShade(name: '110 Porcelana', hex: '#F3D6C1'),
        ProductShade(name: '210 Beige Neutro', hex: '#E0B596'),
        ProductShade(name: '310 Miel Dorada', hex: '#C6906A'),
        ProductShade(name: '420 Bronce Cálido', hex: '#9A6544'),
      ],
      description:
          'Base fluida con textura de sérum que unifica el tono, disimula poros e hidrata durante 24 horas con niacinamida al 4% y ácido hialurónico.',
      ingredients:
          'Aqua, Niacinamide, Sodium Hyaluronate, Titanium Dioxide (SPF 30), Tocopherol, Squalane.',
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-202',
      name: 'Corrector Alta Cobertura Radiant Lift',
      brand: 'Velvet Aura',
      category: 'Bases y correctores',
      price: 23.00,
      stock: 30,
      sku: 'SKU-BAS-202',
      rating: 4.8,
      reviewsCount: 134,
      isFeatured: false,
      isBestSeller: true,
      finish: 'Satinado Anti-Fatiga',
      shadeName: 'Vainilla Luz',
      shadeHex: '#EED0B9',
      shades: const [
        ProductShade(name: 'Vainilla Luz', hex: '#EED0B9'),
        ProductShade(name: 'Durazno Corrector', hex: '#E3AF94'),
        ProductShade(name: 'Almendra Media', hex: '#C79272'),
      ],
      description:
          'Corrector cremoso con cafeína y péptidos que ilumina la ojera al instante, cubre imperfecciones sin cuartearse y descongestiona la mirada.',
      ingredients:
          'Aqua, Glycerin, Caffeine, Palmitoyl Tripeptide-1, Panthenol, Mica.',
      imageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-203',
      name: 'Polvo Compacto Translúcido Airbrush Blur',
      brand: 'Maison Rose',
      category: 'Bases y correctores',
      price: 29.50,
      originalPrice: 35.00,
      stock: 15,
      sku: 'SKU-BAS-203',
      rating: 4.8,
      reviewsCount: 88,
      isFeatured: false,
      isBestSeller: false,
      finish: 'Mate Terciopelo Sin Flashback',
      shadeName: 'Rosa Translúcido',
      shadeHex: '#F4DCD6',
      shades: const [
        ProductShade(name: 'Rosa Translúcido', hex: '#F4DCD6'),
        ProductShade(name: 'Banana Suave', hex: '#F2DFB6'),
        ProductShade(name: 'Caramelo Seda', hex: '#C89876'),
      ],
      description:
          'Polvo microfino con seda hidrolizada que sella el maquillaje, controla el brillo en la zona T y difumina ópticamente la textura de la piel.',
      ingredients: 'Silica, Mica, Lauroyl Lysine, Hydrolyzed Silk, Squalane.',
      imageUrl:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=700&auto=format&fit=crop&q=80',
    ),

    // 3. SOMBRAS
    Product(
      id: 'prod-301',
      name: 'Paleta de Sombras Rose Quartz 12 Tonos',
      brand: 'Glam Studio Paris',
      category: 'Sombras',
      price: 42.00,
      originalPrice: 49.00,
      stock: 18,
      sku: 'SKU-SOM-301',
      rating: 5.0,
      reviewsCount: 192,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Mates Sedosos & Metálicos Cromo',
      shadeName: 'Cuarzo & Champagne',
      shadeHex: '#D88C9A',
      shades: const [
        ProductShade(name: 'Cuarzo & Champagne', hex: '#D88C9A'),
        ProductShade(name: 'Bronce Imperial', hex: '#B67B5B'),
        ProductShade(name: 'Ciruela Ahumado', hex: '#6B2737'),
      ],
      description:
          'Paleta profesional con 12 sombras de ojos ultra pigmentadas en acabados mate mantequilla, satinados perlados y glitter prensado de fácil difuminado.',
      ingredients:
          'Talc-Free Mica, Calcium Sodium Borosilicate, Caprylic/Capric Triglyceride, Jojoba Esters.',
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-302',
      name: 'Sombra Líquida Metálica Starlight Gaze',
      brand: 'Lumière Beauté',
      category: 'Sombras',
      price: 19.90,
      stock: 26,
      sku: 'SKU-SOM-302',
      rating: 4.7,
      reviewsCount: 64,
      isFeatured: false,
      isBestSeller: false,
      finish: 'Lámina Metálica Larga Duración',
      shadeName: 'Oro Rosa Estelar',
      shadeHex: '#E0A39A',
      shades: const [
        ProductShade(name: 'Oro Rosa Estelar', hex: '#E0A39A'),
        ProductShade(name: 'Champagne Perla', hex: '#E8D2B5'),
        ProductShade(name: 'Cobre Solar', hex: '#B8694B'),
      ],
      description:
          'Sombra de ojos líquida de secado rápido con perlas reflectoras de luz. No se acumula en el pliegue del párpado y resiste hasta 14 horas.',
      ingredients:
          'Aqua, Synthetic Fluorphlogopite, Glycerin, PVP, Panthenol.',
      imageUrl:
          'https://images.unsplash.com/photo-1583241800698-e8ab01830a07?w=700&auto=format&fit=crop&q=80',
    ),

    // 4. MÁSCARAS DE PESTAÑAS
    Product(
      id: 'prod-401',
      name: 'Máscara de Pestañas Lash Drama Panorama 4D',
      brand: 'Glam Studio Paris',
      category: 'Máscaras de pestañas',
      price: 22.50,
      originalPrice: 27.00,
      stock: 40,
      sku: 'SKU-MAS-401',
      rating: 4.9,
      reviewsCount: 256,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Volumen Extremo y Curvatura',
      shadeName: 'Negro Obsidiana',
      shadeHex: '#1C1619',
      shades: const [
        ProductShade(name: 'Negro Obsidiana', hex: '#1C1619'),
        ProductShade(name: 'Café Espresso', hex: '#4B2E24'),
        ProductShade(name: 'Borgoña Nocturno', hex: '#581C2B'),
      ],
      description:
          'Máscara de pestañas con cepillo reloj de arena que multiplica el volumen por 4, alarga desde la raíz sin grumos y fortalece con biotina y pantenol.',
      ingredients:
          'Aqua, Cera Alba, Copernicia Cerifera Cera, Panthenol, Biotinoyl Tripeptide-1, Iron Oxides.',
      imageUrl:
          'https://images.unsplash.com/photo-1631214540553-ff044a3ff1d4?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-402',
      name: 'Máscara Waterproof Tubing Lift & Length',
      brand: 'Velvet Aura',
      category: 'Máscaras de pestañas',
      price: 21.00,
      stock: 9,
      sku: 'SKU-MAS-402',
      rating: 4.8,
      reviewsCount: 112,
      isFeatured: false,
      isBestSeller: false,
      finish: 'Definición Pestaña a Pestaña Waterproof',
      shadeName: 'Negro Intenso',
      shadeHex: '#18181B',
      shades: const [
        ProductShade(name: 'Negro Intenso', hex: '#18181B'),
        ProductShade(name: 'Marrón Cálido', hex: '#4E342E'),
      ],
      description:
          'Tecnología de polímeros envolventes resistente al agua, sudor y lágrimas. Eleva las pestañas rectas todo el día sin manchar el párpado.',
      ingredients:
          'Acrylates Copolymer, Aqua, Carnauba Wax, Ricinus Communis Seed Oil, Tocopherol.',
      imageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=700&auto=format&fit=crop&q=80',
    ),

    // 5. PRODUCTOS PARA EL CUIDADO FACIAL
    Product(
      id: 'prod-501',
      name: 'Sérum Facial Hidratante Ácido Hialurónico + B5',
      brand: 'Lumière Beauté',
      category: 'Productos para el cuidado facial',
      price: 34.00,
      originalPrice: 39.50,
      stock: 27,
      sku: 'SKU-SKI-501',
      rating: 4.9,
      reviewsCount: 184,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Piel Jugosa & Rellena (Glass Skin)',
      shadeName: 'Fórmula Cristal 30ml',
      shadeHex: '#F3E5EA',
      shades: const [
        ProductShade(name: 'Fórmula Cristal 30ml', hex: '#F3E5EA'),
      ],
      description:
          'Sérum concentrado con triple peso molecular de ácido hialurónico, provitamina B5 y agua de rosas orgánica. Prepara la piel antes del maquillaje dejándola suave y luminosa.',
      ingredients:
          'Rosa Damascena Flower Water, Sodium Hyaluronate, Panthenol (Vitamina B5), Centella Asiatica Extract.',
      imageUrl:
          'https://images.unsplash.com/photo-1608248597359-0e6d526a6828?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-502',
      name: 'Crema Gel Iluminadora Vitamina C + Péptidos',
      brand: 'Maison Rose',
      category: 'Productos para el cuidado facial',
      price: 36.50,
      stock: 21,
      sku: 'SKU-SKI-502',
      rating: 4.8,
      reviewsCount: 95,
      isFeatured: false,
      isBestSeller: true,
      finish: 'Hidratación Ligera Antioxidante',
      shadeName: 'Tarro de Lujo 50ml',
      shadeHex: '#FAD6A5',
      shades: const [
        ProductShade(name: 'Tarro de Lujo 50ml', hex: '#FAD6A5'),
      ],
      description:
          'Hidratante antioxidante con Vitamina C estabilizada al 10% y ceramidas que revitaliza pieles apagadas, suaviza líneas finas y potencia el acabado de la base.',
      ingredients:
          'Aqua, 3-O-Ethyl Ascorbic Acid, Ceramide NP, Squalane, Butyrospermum Parkii Butter.',
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=700&auto=format&fit=crop&q=80',
    ),

    // 6. ACCESORIOS DE BELLEZA
    Product(
      id: 'prod-601',
      name: 'Set Profesional de 8 Brochas Rose Gold Luxe',
      brand: 'Glam Studio Paris',
      category: 'Accesorios de belleza',
      price: 45.00,
      originalPrice: 54.00,
      stock: 16,
      sku: 'SKU-ACC-601',
      rating: 5.0,
      reviewsCount: 167,
      isFeatured: true,
      isBestSeller: true,
      finish: 'Fibras Taklon Ultra Suaves & Estuche',
      shadeName: 'Rose Gold Edición Limitada',
      shadeHex: '#D4AF37',
      shades: const [
        ProductShade(name: 'Rose Gold Edición Limitada', hex: '#D4AF37'),
        ProductShade(name: 'Rosa Terciopelo', hex: '#D88C9A'),
      ],
      description:
          'Kit completo de 8 brochas veganas de fibra sintética antibacteriana para base, corrector, polvo, contorno, iluminador y difuminado de sombras con virola en baño de oro rosa.',
      ingredients:
          'Fibras Sintéticas Veganas Taklon Grado AAA, Mango de Madera Sustentable, Virola de Aluminio Rose Gold.',
      imageUrl:
          'https://images.unsplash.com/photo-1526045612212-70caf35c14df?w=700&auto=format&fit=crop&q=80',
    ),
    Product(
      id: 'prod-602',
      name: 'Esponja Difuminadora Velvet Blender Pro + Estuche',
      brand: 'Velvet Aura',
      category: 'Accesorios de belleza',
      price: 14.50,
      originalPrice: 18.00,
      stock: 35,
      sku: 'SKU-ACC-602',
      rating: 4.8,
      reviewsCount: 120,
      isFeatured: false,
      isBestSeller: false,
      finish: 'Acabado Aerógrafo Sin Látex',
      shadeName: 'Rosa Malva',
      shadeHex: '#C86D7A',
      shades: const [
        ProductShade(name: 'Rosa Malva', hex: '#C86D7A'),
        ProductShade(name: 'Vino Borgoña', hex: '#6B2737'),
      ],
      description:
          'Esponja hidrofílica libre de látex con corte biselado que duplica su tamaño al humedecerse y aplica bases y correctores con acabado de segunda piel sin absorber producto.',
      ingredients:
          'Poliuretano Hidrofílico Hipoalergénico Libre de Látex + Estuche Ventilado de Viaje.',
      imageUrl:
          'https://images.unsplash.com/photo-1515688594390-b649af70d282?w=700&auto=format&fit=crop&q=80',
    ),
  ];

  List<Product> _localProducts = List.from(_seedProducts);
  List<Product> get currentProducts => List.unmodifiable(_localProducts);

  Future<void> _initializePersistence() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList(_storageKeyFavorites);
      if (savedFavs != null) {
        _favoriteIds
          ..clear()
          ..addAll(savedFavs);
      }

      final rawProducts = prefs.getString(_storageKeyProducts);
      if (rawProducts != null && rawProducts.isNotEmpty) {
        final decoded = jsonDecode(rawProducts) as List<dynamic>;
        final loaded = decoded
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (loaded.isNotEmpty) {
          _localProducts = loaded;
          notifyListeners();
          return;
        }
      }
      await _saveToDisk();
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_localProducts.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKeyProducts, encoded);
    } catch (_) {}
  }

  /// Restaura el catálogo original de cosméticos de fábrica
  Future<void> resetToDefaultCatalog() async {
    _localProducts = List.from(_seedProducts);
    await _saveToDisk();
    notifyListeners();
  }

  /// Obtiene la lista completa de productos sincronizando con API o base persistente local
  Future<List<Product>> getProducts() async {
    await _initializePersistence();

    if (_forcedLocalMode) {
      _isApiOnline = false;
      _statusMessage = 'Base de datos local persistente activa (Modo Offline).';
      return List.unmodifiable(_localProducts);
    }

    final response = await _apiService.fetchProducts();

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      _isApiOnline = true;
      _statusMessage = 'Sincronizado en vivo con API REST (${ApiService.baseUrl}).';
      _localProducts = response.data!;
      await _saveToDisk();
      return List.unmodifiable(_localProducts);
    } else {
      _isApiOnline = false;
      _statusMessage =
          response.message ?? 'Almacenamiento local persistente activo.';
      return List.unmodifiable(_localProducts);
    }
  }

  Product? getById(String id) {
    try {
      return _localProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Agrega un nuevo producto y lo persiste tanto en API como en SharedPreferences
  Future<ProductOperationResult> addProduct(Product product) async {
    if (!_forcedLocalMode) {
      final response = await _apiService.createProduct(product);
      if (response.success && response.data != null) {
        _isApiOnline = true;
        _localProducts.insert(0, response.data!);
        await _saveToDisk();
        notifyListeners();
        return ProductOperationResult(
          success: true,
          product: response.data!,
          message: 'Producto guardado en la API REST y en la base de datos local.',
          isOnline: true,
        );
      }
    }

    _isApiOnline = false;
    _localProducts.insert(0, product);
    await _saveToDisk();
    notifyListeners();
    return ProductOperationResult(
      success: true,
      product: product,
      message: 'Producto guardado en la base de datos persistente del dispositivo.',
      isOnline: false,
    );
  }

  /// Actualiza un producto existente y persiste los cambios
  Future<bool> updateProduct(Product updated) async {
    final index = _localProducts.indexWhere((p) => p.id == updated.id);
    if (index >= 0) {
      _localProducts[index] = updated;
      await _saveToDisk();
      if (!_forcedLocalMode) {
        await _apiService.updateProduct(updated);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Ajusta el inventario de un producto en tiempo real (+ delta o - delta)
  Future<bool> adjustStock(String productId, int delta) async {
    final index = _localProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _localProducts[index];
      final newStock = (current.stock + delta).clamp(0, 9999);
      final updated = current.copyWith(stock: newStock);
      _localProducts[index] = updated;
      await _saveToDisk();
      if (!_forcedLocalMode) {
        await _apiService.updateProduct(updated);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Elimina un producto del catálogo y persiste el cambio
  Future<bool> deleteProduct(String productId) async {
    final index = _localProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _localProducts.removeAt(index);
      _favoriteIds.remove(productId);
      await _saveToDisk();
      if (!_forcedLocalMode) {
        await _apiService.deleteProduct(productId);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Descuenta el stock cuando se procesa un pedido en el carrito
  Future<void> deductStock(String productId, int quantity) async {
    final index = _localProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final cur = _localProducts[index];
      final newStock = (cur.stock - quantity).clamp(0, 9999);
      final updated = cur.copyWith(stock: newStock);
      _localProducts[index] = updated;
      await _saveToDisk();
      if (!_forcedLocalMode) {
        await _apiService.updateProduct(updated);
      }
      notifyListeners();
    }
  }

  /// Calcula el valor total del inventario en existencia
  double get totalInventoryValue {
    return _localProducts.fold(0.0, (acc, p) => acc + (p.price * p.stock));
  }

  /// Cuenta productos con stock bajo (<= 10) o agotados (0)
  int get itemsToRestockCount {
    return _localProducts.where((p) => p.stock <= 10).length;
  }

  /// Propiedades y métodos adicionales utilizados en el panel de administración y navegación
  List<Product> get products => List.unmodifiable(_localProducts);
  int get totalProductsCount => _localProducts.length;
  int get totalStockCount => _localProducts.fold(0, (acc, p) => acc + p.stock);
  String get formattedTotalInventoryValue =>
      '\$${totalInventoryValue.toStringAsFixed(2)} USD';
  int get lowStockCount =>
      _localProducts.where((p) => p.stock > 0 && p.stock <= 10).length;
  int get outOfStockCount => _localProducts.where((p) => p.stock <= 0).length;

  Future<List<Product>> fetchProductsFromApi() => getProducts();
  Future<void> resetToInitialCatalog() => resetToDefaultCatalog();
}

class ProductOperationResult {
  final bool success;
  final Product product;
  final String message;
  final bool isOnline;

  ProductOperationResult({
    required this.success,
    required this.product,
    required this.message,
    required this.isOnline,
  });
}
