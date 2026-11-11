import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Servicio reactivo de carrito de compras con persistencia local automática
/// mediante SharedPreferences (compatible con Android y Flutter Web).
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _loadFromDisk();
  }

  static const String _storageKeyCart = 'glam_studio_persistent_cart_v2';
  static const String _storageKeyOrdersCount = 'glam_studio_orders_count_v2';

  final List<CartItem> _items = [];
  String? _appliedCoupon;
  double _discountAmount = 0.0;
  int _completedOrdersCount = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get appliedCoupon => _appliedCoupon;
  double get discountAmount => _discountAmount;
  int get completedOrdersCount => _completedOrdersCount;

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _completedOrdersCount = prefs.getInt(_storageKeyOrdersCount) ?? 0;
      final raw = prefs.getString(_storageKeyCart);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _items
          ..clear()
          ..addAll(
            list.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e))),
          );
        _recalculateDiscount();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKeyCart, encoded);
      await prefs.setInt(_storageKeyOrdersCount, _completedOrdersCount);
    } catch (_) {}
  }

  int get totalItemsCount {
    return _items.fold(0, (acc, item) => acc + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (acc, item) => acc + item.subtotal);
  }

  double get shipping {
    // Envío gratis en compras desde $50 USD o con cupón ENVIOGRATIS
    if (subtotal == 0 || subtotal >= 50.0 || _appliedCoupon == 'ENVIOGRATIS') {
      return 0.0;
    }
    return 6.50;
  }

  double get total {
    final t = subtotal - _discountAmount + shipping;
    return t > 0 ? t : 0.0;
  }

  // Getters formateados y alias para la pantalla del Carrito y Navegación
  int get itemCount => totalItemsCount;
  String get discountCode => _appliedCoupon ?? '';
  double get shippingCost => shipping;
  double get discountRate {
    switch (_appliedCoupon) {
      case 'GLAM10':
        return 0.10;
      case 'BELLEZA15':
        return 0.15;
      case 'BIENVENIDA20':
        return 0.20;
      default:
        return subtotal > 0 ? (_discountAmount / subtotal) : 0.0;
    }
  }

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)} USD';
  String get formattedDiscount => '\$${_discountAmount.toStringAsFixed(2)} USD';
  String get formattedShipping => '\$${shipping.toStringAsFixed(2)} USD';
  String get formattedTotal => '\$${total.toStringAsFixed(2)} USD';

  bool applyDiscount(String code) => applyCoupon(code);
  void removeDiscount() => removeCoupon();

  void addToCart(
    Product product, {
    int quantity = 1,
    String? shadeName,
    String? shadeHex,
  }) {
    final chosenShadeName = shadeName ?? product.shadeName;
    final chosenShadeHex = shadeHex ?? product.shadeHex;
    final key = '${product.id}__$chosenShadeName';

    final existingIndex = _items.indexWhere((i) => i.uniqueKey == key);
    if (existingIndex >= 0) {
      final nextQty = (_items[existingIndex].quantity + quantity)
          .clamp(1, product.stock > 0 ? product.stock : 99);
      _items[existingIndex].quantity = nextQty;
    } else {
      if (product.stock > 0) {
        _items.add(
          CartItem(
            product: product,
            quantity: quantity.clamp(1, product.stock),
            selectedShadeName: chosenShadeName,
            selectedShadeHex: chosenShadeHex,
          ),
        );
      }
    }
    _recalculateDiscount();
    _saveToDisk();
    notifyListeners();
  }

  void increment(String uniqueOrProductId) {
    final index = _items.indexWhere(
      (i) => i.uniqueKey == uniqueOrProductId || i.product.id == uniqueOrProductId,
    );
    if (index >= 0) {
      if (_items[index].quantity < _items[index].product.stock) {
        _items[index].quantity++;
        _recalculateDiscount();
        _saveToDisk();
        notifyListeners();
      }
    }
  }

  void decrement(String uniqueOrProductId) {
    final index = _items.indexWhere(
      (i) => i.uniqueKey == uniqueOrProductId || i.product.id == uniqueOrProductId,
    );
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _recalculateDiscount();
      _saveToDisk();
      notifyListeners();
    }
  }

  void remove(String uniqueOrProductId) {
    _items.removeWhere(
      (i) => i.uniqueKey == uniqueOrProductId || i.product.id == uniqueOrProductId,
    );
    _recalculateDiscount();
    _saveToDisk();
    notifyListeners();
  }

  void clear({bool isCheckout = false}) {
    if (isCheckout && _items.isNotEmpty) {
      _completedOrdersCount++;
    }
    _items.clear();
    _appliedCoupon = null;
    _discountAmount = 0.0;
    _saveToDisk();
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    const validCodes = [
      'GLAM10',
      'BIENVENIDA20',
      'BELLEZA15',
      'ENVIOGRATIS',
      'TECH10',
      'VANGUARD10',
    ];
    if (validCodes.contains(clean)) {
      _appliedCoupon = clean;
      _recalculateDiscount();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  void _recalculateDiscount() {
    if (_appliedCoupon == null || subtotal <= 0) {
      _discountAmount = 0.0;
      return;
    }
    switch (_appliedCoupon) {
      case 'GLAM10':
        _discountAmount = subtotal * 0.10;
        break;
      case 'BELLEZA15':
        _discountAmount = subtotal * 0.15;
        break;
      case 'BIENVENIDA20':
        _discountAmount = subtotal * 0.20;
        break;
      case 'ENVIOGRATIS':
        _discountAmount = 0.0;
        break;
      default:
        _discountAmount = 10.0;
        break;
    }
    if (_discountAmount > subtotal) {
      _discountAmount = subtotal;
    }
  }
}
