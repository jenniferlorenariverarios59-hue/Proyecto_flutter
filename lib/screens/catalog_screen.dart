import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/add_product_sheet.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/metric_card.dart';
import '../widgets/product_card.dart';
import 'product_detail_sheet.dart';

/// Pantalla de Catálogo y Buscador de Productos de Belleza en Glam Studio.
/// Incluye:
/// - Buscador en tiempo real por nombre, marca, tono, categoría o SKU
/// - Filtro por las 6 categorías oficiales de maquillaje y por disponibilidad
/// - Ordenamiento por precio, calificación o destacados
/// - Selector de vista: Cuadrícula (Grid adaptable a celular y PC) o Lista detallada
/// - Botón flotante para Agregar Producto.
class CatalogScreen extends StatefulWidget {
  final VoidCallback? onOpenCart;
  final String? initialCategory;

  const CatalogScreen({
    super.key,
    this.onOpenCart,
    this.initialCategory,
  });

  @override
  State<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  final ProductRepository _repository = ProductRepository();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _useGridView = true;
  String _sortBy = 'featured'; // featured, price_asc, price_desc, rating

  String _selectedCategory = 'Todos';
  String _selectedStatus = 'all';
  String _searchQuery = '';

  final List<String> _categories = [
    'Todos',
    ...Product.officialCategories,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null &&
        _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
    _repository.addListener(_onRepositoryChanged);
    _cart.addListener(_onCartChanged);
    _loadCatalog();
  }

  /// Permite que el contenedor principal cambie la categoría activa desde la pantalla de Inicio.
  void selectCategoryFromExternal(String category) {
    if (_categories.contains(category)) {
      setState(() {
        _selectedCategory = category;
        _applyFilters();
      });
    }
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    _cart.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepositoryChanged() {
    _loadCatalog(showLoading: false);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCatalog({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    final products = await _repository.getProducts();

    if (mounted) {
      setState(() {
        _allProducts = products;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase().trim();

    List<Product> list = _allProducts.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.shadeName.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'Todos' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesStatus =
          _selectedStatus == 'all' || p.status == _selectedStatus;

      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort(
          (a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
        );
    }

    setState(() {
      _filteredProducts = list;
    });
  }

  Future<void> _handleProductSave(Product product) async {
    final result = await _repository.addProduct(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.inverseSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.softGold,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡"${result.product.name}" registrado!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      result.message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'Todos';
      _selectedStatus = 'all';
      _sortBy = 'featured';
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompactMobile = width < 430;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Catálogo de Cosméticos',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Tooltip(
              message: _repository.statusMessage,
              child: Chip(
                visualDensity: isCompactMobile
                    ? VisualDensity.compact
                    : VisualDensity.standard,
                avatar: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _repository.isApiOnline
                        ? AppTheme.secondary
                        : AppTheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                label: Text(
                  _repository.isApiOnline
                      ? (isCompactMobile ? 'API' : 'API Conectada')
                      : (isCompactMobile ? 'BD Local' : 'BD Local Activa'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _repository.isApiOnline
                        ? AppTheme.secondary
                        : AppTheme.primaryContainer,
                  ),
                ),
                backgroundColor: _repository.isApiOnline
                    ? AppTheme.secondaryContainer
                    : AppTheme.primaryFixed,
                side: BorderSide.none,
              ),
            ),
          ),
          // Alternar vista Cuadrícula vs Lista
          IconButton(
            tooltip: _useGridView ? 'Cambiar a vista lista' : 'Cambiar a cuadrícula',
            icon: Icon(
              _useGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _useGridView = !_useGridView),
          ),
          if (widget.onOpenCart != null)
            IconButton(
              tooltip: 'Ver Carrito de Compras',
              onPressed: widget.onOpenCart,
              icon: Badge(
                isLabelVisible: _cart.totalItemsCount > 0,
                label: Text('${_cart.totalItemsCount}'),
                backgroundColor: AppTheme.primaryContainer,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          IconButton(
            tooltip: 'Sincronizar catálogo',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadCatalog(showLoading: true),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryContainer,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cargando colección de maquillaje...',
                        style: TextStyle(color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryContainer,
                  onRefresh: () => _loadCatalog(showLoading: false),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    children: [
                      _buildSearchAndSortBar(),
                      const SizedBox(height: 14),

                      QuickMetricsBento(
                        totalCount: _allProducts.length,
                        totalValue: _repository.totalInventoryValue,
                        restockCount: _repository.itemsToRestockCount,
                      ),
                      const SizedBox(height: 16),

                      FilterChipsBar(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        selectedStatus: _selectedStatus,
                        onCategorySelected: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                            _applyFilters();
                          });
                        },
                        onStatusSelected: (status) {
                          setState(() {
                            _selectedStatus = status;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Productos encontrados (${_filteredProducts.length})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedCategory != 'Todos' ||
                              _selectedStatus != 'all')
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.close, size: 15),
                              label: const Text(
                                'Limpiar filtros',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_filteredProducts.isEmpty)
                        _buildEmptyState()
                      else if (_useGridView)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxW = constraints.maxWidth;
                            int gridColumns = 2;
                            if (maxW >= 980) {
                              gridColumns = 4;
                            } else if (maxW >= 680) {
                              gridColumns = 3;
                            } else if (maxW < 330) {
                              gridColumns = 1;
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                mainAxisExtent: 318,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final prod = _filteredProducts[index];
                                return ProductCard(
                                  product: prod,
                                  isGridMode: true,
                                  onTap: () => ProductDetailSheet.show(
                                    context,
                                    prod,
                                    onProductModified: () =>
                                        _loadCatalog(showLoading: false),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      else
                        ..._filteredProducts.map(
                          (prod) => ProductCard(
                            product: prod,
                            isGridMode: false,
                            onTap: () => ProductDetailSheet.show(
                              context,
                              prod,
                              onProductModified: () =>
                                  _loadCatalog(showLoading: false),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddProductSheet.show(
          context,
          onSave: _handleProductSave,
        ),
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Nuevo Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant),
              boxShadow: AppTheme.luxuryShadow,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText:
                    'Buscar por nombre, marca, tono o categoría...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primaryContainer,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppTheme.outline,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          tooltip: 'Ordenar productos',
          initialValue: _sortBy,
          onSelected: (val) {
            setState(() {
              _sortBy = val;
              _applyFilters();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'featured',
              child: Text('Destacados'),
            ),
            PopupMenuItem(
              value: 'price_asc',
              child: Text('Precio: Menor a Mayor'),
            ),
            PopupMenuItem(
              value: 'price_desc',
              child: Text('Precio: Mayor a Menor'),
            ),
            PopupMenuItem(
              value: 'rating',
              child: Text('Mejor Calificación'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppTheme.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              size: 36,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No encontramos cosméticos con ese criterio',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba con otra categoría o restablece los filtros de búsqueda.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Restablecer filtros'),
          ),
        ],
      ),
    );
  }
}
