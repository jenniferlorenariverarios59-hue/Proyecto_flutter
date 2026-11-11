import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/add_product_sheet.dart';
import '../widgets/product_card.dart';
import 'product_detail_sheet.dart';

/// Pantalla de Inicio (Home) de Glam Studio con estética editorial de alta cosmética.
/// Presenta:
/// - Bienvenida personalizada con el usuario activo
/// - Buscador directo
/// - Banner Hero de colección y cupones de descuento aplicables con 1 clic
/// - Tarjetas interactivas de las 6 categorías oficiales solicitadas
/// - Carrusel de Productos Destacados y Más Vendidos
/// - Botón directo para registrar nuevos productos.
class HomeScreen extends StatefulWidget {
  final void Function({String? category, String? searchQuery}) onNavigateToCatalog;
  final VoidCallback onNavigateToCart;
  final VoidCallback onNavigateToAdmin;

  const HomeScreen({
    super.key,
    required this.onNavigateToCatalog,
    required this.onNavigateToCart,
    required this.onNavigateToAdmin,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _repository = ProductRepository();
  final CartService _cart = CartService();
  final AuthService _auth = AuthService();

  List<Product> _products = [];
  bool _isLoading = true;

  static const List<Map<String, dynamic>> _categoriesMeta = [
    {
      'name': 'Labiales',
      'subtitle': 'Mates, satinados y lip oils',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFC85A70),
      'image':
          'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Bases y correctores',
      'subtitle': 'Cobertura luminosa SPF 30',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFFC89678),
      'image':
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Sombras',
      'subtitle': 'Paletas minerales & cromo',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF8A3E52),
      'image':
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Máscaras de pestañas',
      'subtitle': 'Volumen 4D y waterproof',
      'icon': Icons.remove_red_eye_rounded,
      'color': Color(0xFF4E1624),
      'image':
          'https://images.unsplash.com/photo-1631214540553-ff044a3ff1d4?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Productos para el cuidado facial',
      'subtitle': 'Sérums, vitamina C y ácido hialurónico',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF3E7A65),
      'image':
          'https://images.unsplash.com/photo-1608248597359-0e6d526a6828?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Accesorios de belleza',
      'subtitle': 'Brochas Rose Gold y esponjas',
      'icon': Icons.brush_rounded,
      'color': Color(0xFFB5892E),
      'image':
          'https://images.unsplash.com/photo-1526045612212-70caf35c14df?w=500&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepoChanged);
    _cart.addListener(_onCartChanged);
    _auth.addListener(_onCartChanged);
    _loadData();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    _cart.removeListener(_onCartChanged);
    _auth.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    _loadData(showLoading: false);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }
    final items = await _repository.getProducts();
    if (mounted) {
      setState(() {
        _products = items;
        _isLoading = false;
      });
    }
  }

  void _activatePromoCode(String code) {
    _cart.applyCoupon(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          '¡Cupón $code activado! El descuento se aplicará automáticamente en tu carrito.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final firstName = (user?.name ?? 'Invitada').split(' ').first;
    final featured = _products.where((p) => p.isFeatured).toList();
    final bestSellers = _products.where((p) => p.isBestSeller).toList();
    final width = MediaQuery.of(context).size.width;
    final isCompactMobile = width < 400;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: AppTheme.softGold,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Glam Studio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, height: 1.05),
                  ),
                  Text(
                    'Hola, $firstName • Piel ${user?.skinType ?? "Mixta"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Indicador de estado de base de datos / API REST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              onPressed: widget.onNavigateToAdmin,
              visualDensity: isCompactMobile
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              avatar: Icon(
                _repository.isApiOnline
                    ? Icons.cloud_done_rounded
                    : Icons.storage_rounded,
                size: 15,
                color: _repository.isApiOnline
                    ? AppTheme.secondary
                    : AppTheme.primaryContainer,
              ),
              label: Text(
                _repository.isApiOnline
                    ? 'API Online'
                    : (isCompactMobile ? 'BD Local' : 'BD Persistente'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Mi Carrito',
            onPressed: widget.onNavigateToCart,
            icon: Badge(
              isLabelVisible: _cart.totalItemsCount > 0,
              label: Text('${_cart.totalItemsCount}'),
              backgroundColor: AppTheme.primaryContainer,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryContainer,
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primaryContainer,
              onRefresh: () => _loadData(showLoading: false),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    children: [
                      // 1. Buscador rápido interactivo
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.luxuryShadow,
                        ),
                        child: Material(
                          color: AppTheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: AppTheme.outlineVariant,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => widget.onNavigateToCatalog(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.primaryContainer,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Buscar labiales, bases, sombras, cuidado facial o accesorios...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.outline,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryFixed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Explorar',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Hero Banner de Colección de Belleza
                      _buildHeroBanner(context),
                      const SizedBox(height: 24),

                      // 3. Sección de las 6 Categorías Oficiales de Maquillaje
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categorías de Maquillaje y Belleza',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 20),
                                ),
                                const Text(
                                  'Selecciona una línea para filtrar el catálogo',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () =>
                                widget.onNavigateToCatalog(category: 'Todos'),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                            label: const Text('Ver todas'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxW = constraints.maxWidth;
                          final cols = maxW >= 920
                              ? 3
                              : (maxW >= 520 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisExtent: 102,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _categoriesMeta.length,
                            itemBuilder: (context, index) {
                              final cat = _categoriesMeta[index];
                              final name = cat['name'] as String;
                              final sub = cat['subtitle'] as String;
                              final color = cat['color'] as Color;
                              final icon = cat['icon'] as IconData;
                              final count = _products
                                  .where((p) => p.category == name)
                                  .length;

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.luxuryShadow,
                                ),
                                child: Material(
                                  color: AppTheme.surfaceContainerLowest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: color.withValues(alpha: 0.28),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => widget.onNavigateToCatalog(
                                      category: name,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.14,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              icon,
                                              color: color,
                                              size: 25,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13.5,
                                                    color: AppTheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  sub,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '$count productos',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                            color: AppTheme.outline,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      // 4. Carrusel de Productos Destacados
                      _buildHorizontalProductSection(
                        context,
                        title: 'Colección Destacada de Temporada',
                        subtitle:
                            'Fórmulas de alta pigmentación y cuidado dermatológico',
                        items: featured.isNotEmpty ? featured : _products,
                      ),

                      const SizedBox(height: 24),

                      // 5. Carrusel de Más Vendidos
                      _buildHorizontalProductSection(
                        context,
                        title: 'Favoritos de la Comunidad Glam',
                        subtitle:
                            'Los productos mejor calificados por nuestras clientas',
                        items: bestSellers.isNotEmpty ? bestSellers : _products,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddProductSheet.show(
            context,
            onSave: (newProd) async {
              final res = await _repository.addProduct(newProd);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡"${res.product.name}" registrado con éxito!'),
                  backgroundColor: AppTheme.secondary,
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar Producto'),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4E1624),
            Color(0xFF6B2737),
            Color(0xFFA85166),
          ],
        ),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'COLECCIÓN HAUTE BEAUTÉ • ENVÍO GRATIS DESDE \$50',
              style: TextStyle(
                color: AppTheme.softGold,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Realza tu Belleza con Alta Cosmética',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Labiales mate aterciopelados, bases sérum con ácido hialurónico, sombras minerales y brochas profesionales Rose Gold.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryContainer,
                ),
                onPressed: () => widget.onNavigateToCatalog(category: 'Todos'),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('Explorar Catálogo'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.softGold,
                  side: const BorderSide(color: AppTheme.softGold, width: 1.4),
                ),
                onPressed: () => _activatePromoCode('BIENVENIDA20'),
                icon: const Icon(Icons.local_offer_outlined, size: 17),
                label: const Text('Activar 20% OFF (BIENVENIDA20)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Product> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 20),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateToCatalog(category: 'Todos'),
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 318,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final prod = items[index];
              return SizedBox(
                width: 215,
                child: ProductCard(
                  product: prod,
                  isGridMode: true,
                  onTap: () => ProductDetailSheet.show(
                    context,
                    prod,
                    onProductModified: () => _loadData(showLoading: false),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
