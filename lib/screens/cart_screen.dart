import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'product_detail_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  final AuthService _auth = AuthService();
  final TextEditingController _couponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    _couponCtrl.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return AppTheme.secondaryColor;
  }

  void _applyCoupon([String? presetCode]) {
    final code = (presetCode ?? _couponCtrl.text).trim();
    if (code.isEmpty) return;

    final success = _cart.applyDiscount(code);
    if (success) {
      _couponCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Cupón "${code.toUpperCase()}" aplicado con éxito!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cupón no válido. Prueba con GLAM10, BIENVENIDA20, BELLEZA15 o ENVIOGRATIS',
          ),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _checkout() {
    if (_cart.items.isEmpty) return;

    final orderTotal = _cart.formattedTotal;
    final itemsCount = _cart.itemCount;
    final customerName = _auth.currentUser?.name ?? 'Cliente Glam Studio';
    final orderNumber =
        'GLAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.14),
                    AppTheme.secondaryColor.withValues(alpha: 0.25),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primaryColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Pedido Confirmado!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Orden #$orderNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gracias por tu compra, $customerName. Hemos procesado $itemsCount ${itemsCount == 1 ? 'producto' : 'productos'} de belleza y actualizado el inventario en tiempo real.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total pagado:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    orderTotal,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _cart.clear(isCheckout: true);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Seguir Explorando la Boutique'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 920;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bolsa de Compras',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items.isEmpty
                                  ? 'Tu bolsa de maquillaje está vacía'
                                  : '${_cart.itemCount} ${_cart.itemCount == 1 ? 'artículo seleccionado' : 'artículos seleccionados'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (items.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            _cart.clear();
                          },
                          icon: const Icon(
                            Icons.delete_sweep_outlined,
                            color: AppTheme.dangerColor,
                            size: 20,
                          ),
                          label: const Text(
                            'Vaciar bolsa',
                            style: TextStyle(
                              color: AppTheme.dangerColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (items.isEmpty)
                  Expanded(child: _buildEmptyState())
                else if (isWide)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _buildCartItemsList(items),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 390,
                            child: SingleChildScrollView(
                              child: _buildOrderSummaryCard(isWide: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCartItemsList(items),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (MediaQuery.of(context).size.height * 0.48)
                          .clamp(160.0, 430.0),
                    ),
                    child: SingleChildScrollView(
                      child: _buildOrderSummaryCard(isWide: false),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tu bolsa de belleza está vacía',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora nuestros labiales, bases, sombras, cuidado facial y accesorios para armar tu rutina ideal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsList(List<CartItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCartItemCard(item);
      },
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          GestureDetector(
            onTap: () => ProductDetailSheet.show(context, p),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 82,
                height: 88,
                color: const Color(0xFFF9F1F3),
                child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? Image.network(
                        p.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.spa_rounded,
                          color: AppTheme.secondaryColor,
                          size: 32,
                        ),
                      )
                    : const Icon(
                        Icons.spa_rounded,
                        color: AppTheme.secondaryColor,
                        size: 32,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Product Details & Shade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.brand.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                if (item.selectedShadeName.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseHex(item.selectedShadeHex),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width: 0.8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Tono: ${item.selectedShadeName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.formattedSubtotal,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (item.quantity > 1)
                      Text(
                        '(${p.formattedPrice} c/u)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Quantity Controls + Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _cart.remove(item.uniqueKey),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                tooltip: 'Eliminar del carrito',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 4),
              Material(
                color: AppTheme.backgroundLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _cart.decrement(item.uniqueKey),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: item.quantity < p.stock
                          ? () => _cart.increment(item.uniqueKey)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: item.quantity < p.stock
                              ? AppTheme.primaryColor
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard({required bool isWide}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isWide
            ? BorderRadius.circular(22)
            : const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Compra',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Coupon section
          if (_cart.discountCode.isEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _couponCtrl,
                      decoration: InputDecoration(
                        hintText: 'Código promocional (ej: GLAM10)',
                        hintStyle: const TextStyle(fontSize: 12.5),
                        prefixIcon: const Icon(
                          Icons.local_offer_outlined,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCouponChip('GLAM10', '10% Dto'),
                  const SizedBox(width: 6),
                  _buildCouponChip('BELLEZA15', '15% Dto'),
                  const SizedBox(width: 6),
                  _buildCouponChip('BIENVENIDA20', '20% Dto'),
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.successColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cupón "${_cart.discountCode}" activo (-${(_cart.discountRate * 100).toInt()}%)',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _cart.removeDiscount,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal productos', _cart.formattedSubtotal),
          if (_cart.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Descuento promocional',
              '-${_cart.formattedDiscount}',
              valueColor: AppTheme.successColor,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Envío nacional',
            _cart.shippingCost == 0 ? '¡GRATIS!' : _cart.formattedShipping,
            valueColor: _cart.shippingCost == 0 ? AppTheme.successColor : null,
          ),
          if (_cart.shippingCost > 0)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Envío gratis en compras superiores a \$150.000 COP',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total a Pagar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                _cart.formattedTotal,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _checkout,
              icon: const Icon(Icons.lock_outline_rounded, size: 19),
              label: const Text(
                'Confirmar Pedido Seguro',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponChip(String code, String label) {
    return ActionChip(
      onPressed: () => _applyCoupon(code),
      backgroundColor: AppTheme.backgroundLight,
      side: const BorderSide(color: AppTheme.borderColor),
      avatar: const Icon(
        Icons.auto_awesome_rounded,
        size: 14,
        color: AppTheme.primaryColor,
      ),
      label: Text(
        '$code ($label)',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
