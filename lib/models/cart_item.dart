import 'product.dart';

/// Elemento del carrito de compras de Glam Studio con soporte de tono cosmético y persistencia JSON.
class CartItem {
  final Product product;
  final String selectedShadeName;
  final String selectedShadeHex;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
    String? selectedShadeName,
    String? selectedShadeHex,
  })  : selectedShadeName = selectedShadeName ?? product.shadeName,
        selectedShadeHex = selectedShadeHex ?? product.shadeHex;

  String get uniqueKey => '${product.id}__$selectedShadeName';

  double get subtotal => product.price * quantity;

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)} USD';

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final prod = Product.fromJson(Map<String, dynamic>.from(json['product'] as Map));
    return CartItem(
      product: prod,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedShadeName: json['selectedShadeName']?.toString() ?? prod.shadeName,
      selectedShadeHex: json['selectedShadeHex']?.toString() ?? prod.shadeHex,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'selectedShadeName': selectedShadeName,
        'selectedShadeHex': selectedShadeHex,
      };
}
