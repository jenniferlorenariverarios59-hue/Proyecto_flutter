import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_product_sheet.dart';

/// Hoja modal / vista detallada de producto de belleza en Glam Studio.
/// Permite:
/// - Seleccionar tonos cosméticos con muestras reales de color (swatches).
/// - Elegir cantidad y agregar al carrito con el tono seleccionado.
/// - Ver descripción, acabado, ingredientes activos y calificación.
/// - Administrar el producto: Editar datos, Ajustar Stock en vivo y Eliminar.
class ProductDetailSheet extends StatefulWidget {
  final Product product;
  final VoidCallback? onProductModified;

  const ProductDetailSheet({
    super.key,
    required this.product,
    this.onProductModified,
  });

  static void show(
    BuildContext context,
    Product product, {
    VoidCallback? onProductModified,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductDetailSheet(
        product: product,
        onProductModified: onProductModified,
      ),
    );
  }

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _selectedShadeIndex = 0;
  int _quantity = 1;

  Product get product => widget.product;

  ProductShade get _activeShade {
    if (_selectedShadeIndex < product.shades.length) {
      return product.shades[_selectedShadeIndex];
    }
    return product.shades.first;
  }

  void _handleAddToCart(BuildContext context) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este cosmético está agotado temporalmente.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    CartService().addToCart(
      product,
      quantity: _quantity,
      shadeName: _activeShade.name,
      shadeHex: _activeShade.hex,
    );
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              color: AppTheme.softGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡$_quantity x "${product.name}" (${_activeShade.name}) añadido al carrito!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    EditProductSheet.show(
      context,
      product: product,
      onSave: (updated) async {
        await ProductRepository().updateProduct(updated);
        if (context.mounted) {
          Navigator.of(context).pop();
          widget.onProductModified?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${updated.name}" actualizado correctamente.'),
              backgroundColor: AppTheme.secondary,
            ),
          );
        }
      },
    );
  }

  void _handleAdjustStock(BuildContext context) {
    int tempDelta = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppTheme.primaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ajustar Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Existencias actuales: ${product.stock} unidades',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => setDlgState(() => tempDelta--),
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    tempDelta >= 0 ? '+$tempDelta' : '$tempDelta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          tempDelta >= 0 ? AppTheme.secondary : AppTheme.error,
                    ),
                  ),
                  const SizedBox(width: 18),
                  IconButton.filledTonal(
                    onPressed: () => setDlgState(() => tempDelta++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nuevo total: ${(product.stock + tempDelta).clamp(0, 9999)} uds.',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ProductRepository().adjustStock(product.id, tempDelta);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  widget.onProductModified?.call();
                }
              },
              child: const Text('Guardar Ajuste'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('¿Eliminar producto del catálogo?'),
        content: Text(
          'Se eliminará "${product.name}" de la tienda y la base de datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ProductRepository().deleteProduct(product.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                widget.onProductModified?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${product.name}" eliminado del catálogo.'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final repo = ProductRepository();
    final isFav = repo.isFavorite(product.id);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: media.size.height * 0.92,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Barra de arrastre
              Container(
                width: 46,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  children: [
                    // Imagen principal con matiz del tono seleccionado
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 260,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _buildFallback(),
                                    )
                                  : _buildFallback(),
                              // Velo sutil con el color del tono elegido
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomRight,
                                    end: Alignment.topLeft,
                                    colors: [
                                      _activeShade.color.withValues(alpha: 0.32),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.93),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryContainer,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? AppTheme.secondaryContainer
                                      : AppTheme.errorContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  product.statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: product.stock > 0
                                        ? AppTheme.onSecondaryContainer
                                        : AppTheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () async {
                                    await repo.toggleFavorite(product.id);
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 19,
                                      color: isFav
                                          ? const Color(0xFFD62849)
                                          : AppTheme.primaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Marca, SKU y barra de acciones de Administración (Stock / Editar / Eliminar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.brand.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryContainer,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              Text(
                                '${product.sku} • ${product.finish}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Ajustar Stock',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 19,
                                ),
                                onPressed: () => _handleAdjustStock(context),
                              ),
                              IconButton(
                                tooltip: 'Editar Producto',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 19,
                                  color: AppTheme.primaryContainer,
                                ),
                                onPressed: () => _handleEdit(context),
                              ),
                              IconButton(
                                tooltip: 'Eliminar Producto',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19,
                                  color: AppTheme.error,
                                ),
                                onPressed: () => _handleDelete(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Nombre del producto
                    Text(
                      product.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 23,
                                height: 1.2,
                              ),
                    ),
                    const SizedBox(height: 10),

                    // Precio y Calificación
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)} USD',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryContainer,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.outline,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.champagne,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.softGold,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} (${product.reviewsCount} reseñas)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Selector de Tonos Cosméticos (Swatches)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tono seleccionado: ${_activeShade.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: List.generate(product.shades.length, (i) {
                              final shade = product.shades[i];
                              final selected = i == _selectedShadeIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedShadeIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primaryContainer
                                          : AppTheme.outlineVariant,
                                      width: selected ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: shade.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        shade.name,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Descripción
                    const Text(
                      'Descripción y Beneficios',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ingredientes activos
                    const Text(
                      'Ingredientes Clave',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.ingredients,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),

              // Barra inferior fija: selector de cantidad + Añadir al Carrito
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: media.padding.bottom + 14,
                  top: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  border: Border(
                    top: BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    // Selector de cantidad (+ / -)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove_rounded, size: 18),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            onPressed: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: product.stock > 0
                              ? () => _handleAddToCart(context)
                              : null,
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                          ),
                          label: Text(
                            product.stock > 0
                                ? 'Agregar • \$${(product.price * _quantity).toStringAsFixed(2)}'
                                : 'Agotado',
                          ),
                        ),
                      ),
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

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _activeShade.color.withValues(alpha: 0.4),
            AppTheme.primaryFixed,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 64,
          color: AppTheme.primaryContainer,
        ),
      ),
    );
  }
}
