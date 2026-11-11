import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';

/// Tarjeta editorial de producto de maquillaje y belleza para Glam Studio.
/// Soporta diseño en cuadrícula (grid) y en lista horizontal, mostrando fotografía,
/// categoría, marca, nombre, muestras de tonos (swatches), precio, calificación,
/// estado de stock y botón directo de agregar al carrito.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isGridMode;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isGridMode = false,
  });

  void _quickAddToCart(BuildContext context) {
    if (product.stock <= 0) return;
    CartService().addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.inverseSurface,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              color: AppTheme.softGold,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡"${product.name}" (${product.shadeName}) agregado al carrito!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGridMode) {
      return _buildGridCard(context);
    }
    return _buildHorizontalCard(context);
  }

  /// Diseño de tarjeta vertical tipo Boutique para cuadrículas y carruseles
  Widget _buildGridCard(BuildContext context) {
    final repo = ProductRepository();
    final isFav = repo.isFavorite(product.id);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Material(
        color: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppTheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotografía del cosmético + insignias + favorito + tonos
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppTheme.surfaceContainerLow,
                      child: (product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty)
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackIcon(),
                            )
                          : _buildFallbackIcon(),
                    ),
                    // Sombra suave inferior para resaltar las muestras de tonos
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.42),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Etiqueta de categoría o descuento
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 44,
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          if (product.hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              product.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.primaryContainer,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de favorito
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => repo.toggleFavorite(product.id),
                          child: Padding(
                            padding: const EdgeInsets.all(6.5),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 17,
                              color: isFav
                                  ? const Color(0xFFD62849)
                                  : AppTheme.primaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Muestras de tonos cosméticos disponibles
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          ...product.shades.take(4).map(
                                (s) => Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                          const Spacer(),
                          Flexible(child: _buildStockBadge(compact: true)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Detalles del producto
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.brand.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurfaceVariant,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.softGold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppTheme.outline,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: product.stock > 0
                              ? AppTheme.primaryContainer
                              : AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: product.stock > 0
                                ? () => _quickAddToCart(context)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              child: Icon(
                                product.stock > 0
                                    ? Icons.add_shopping_cart_rounded
                                    : Icons.block_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Diseño de tarjeta horizontal detallada con fotografía, tono y acción rápida
  Widget _buildHorizontalCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Material(
        color: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(context),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.brand.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryContainer,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppTheme.softGold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // Muestra de tonos cosméticos y acabado
                      Row(
                        children: [
                          ...product.shades.take(3).map(
                                (s) => Container(
                                  width: 13,
                                  height: 13,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.outlineVariant,
                                    ),
                                  ),
                                ),
                              ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${product.shadeName} • ${product.finish}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: product.stock > 0
                                      ? AppTheme.primaryContainer
                                      : AppTheme.outline,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.outline,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStockBadge(compact: false),
                              const SizedBox(width: 8),
                              Material(
                                color: product.stock > 0
                                    ? AppTheme.primaryContainer
                                    : AppTheme.outlineVariant,
                                borderRadius: BorderRadius.circular(11),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(11),
                                  onTap: product.stock > 0
                                      ? () => _quickAddToCart(context)
                                      : null,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildFallbackIcon(),
                )
              : _buildFallbackIcon(),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              product.category,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    IconData icon;
    switch (product.category) {
      case 'Labiales':
        icon = Icons.favorite_rounded;
        break;
      case 'Bases y correctores':
        icon = Icons.face_retouching_natural_rounded;
        break;
      case 'Sombras':
        icon = Icons.palette_rounded;
        break;
      case 'Máscaras de pestañas':
        icon = Icons.remove_red_eye_rounded;
        break;
      case 'Productos para el cuidado facial':
        icon = Icons.spa_rounded;
        break;
      case 'Accesorios de belleza':
        icon = Icons.brush_rounded;
        break;
      default:
        icon = Icons.auto_awesome_rounded;
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            product.primaryShadeColor.withValues(alpha: 0.35),
            AppTheme.primaryFixed,
          ],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 38, color: AppTheme.primaryContainer),
      ),
    );
  }

  Widget _buildStockBadge({required bool compact}) {
    Color bg;
    Color fg;
    String label;

    if (product.stock == 0) {
      bg = AppTheme.errorContainer;
      fg = AppTheme.onErrorContainer;
      label = 'Agotado';
    } else if (product.stock <= 10) {
      bg = AppTheme.tertiaryContainer;
      fg = AppTheme.onTertiaryContainer;
      label = compact ? '${product.stock} uds.' : 'Últimas ${product.stock}';
    } else {
      bg = AppTheme.secondaryContainer;
      fg = AppTheme.onSecondaryContainer;
      label = '${product.stock} disp.';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
