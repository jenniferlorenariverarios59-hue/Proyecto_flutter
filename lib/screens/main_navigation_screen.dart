import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/add_product_sheet.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final CartService _cart = CartService();
  final ProductRepository _repo = ProductRepository();
  final AuthService _auth = AuthService();
  final GlobalKey<CatalogScreenState> _catalogKey =
      GlobalKey<CatalogScreenState>();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onStateChanged);
    _repo.addListener(_onStateChanged);
    _auth.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onStateChanged);
    _repo.removeListener(_onStateChanged);
    _auth.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _navigateToCatalogWithCategory({String? category, String? searchQuery}) {
    setState(() {
      _currentIndex = 1;
    });
    if (category != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _catalogKey.currentState?.selectCategoryFromExternal(category);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si el usuario no ha iniciado sesión, mostrar pantalla de Login / Registro
    if (!_auth.isAuthenticated) {
      return const AuthScreen();
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 880;

    final screens = [
      HomeScreen(
        onNavigateToCatalog: _navigateToCatalogWithCategory,
        onNavigateToCart: () => setState(() => _currentIndex = 2),
        onNavigateToAdmin: () => setState(() => _currentIndex = 3),
      ),
      CatalogScreen(
        key: _catalogKey,
        onOpenCart: () => setState(() => _currentIndex = 2),
      ),
      const CartScreen(),
      const SettingsScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Row(
          children: [
            _buildDesktopSidebar(context),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.secondaryColor.withValues(alpha: 0.25),
          height: 68,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Catálogo',
            ),
            NavigationDestination(
              icon: _buildCartBadgeIcon(isSelected: false),
              selectedIcon: _buildCartBadgeIcon(isSelected: true),
              label: 'Bolsa',
            ),
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(
                Icons.admin_panel_settings_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Admin / Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    final user = _auth.currentUser;

    return Material(
      color: Colors.white,
      child: Container(
        width: 260,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 40).clamp(0.0, double.infinity),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B2737),
                                      Color(0xFF9E3B52),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFFF9E498),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GLAM STUDIO',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 1.4,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'MAQUILLAJE & BELLEZA',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Quick Add Product CTA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => AddProductSheet.show(
                              context,
                              onSave: (prod) async {
                                await _repo.addProduct(prod);
                              },
                            ),
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Agregar Producto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'MENÚ PRINCIPAL',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildSidebarItem(
                          index: 0,
                          icon: Icons.auto_awesome_outlined,
                          selectedIcon: Icons.auto_awesome_rounded,
                          label: 'Inicio & Tendencias',
                        ),
                        const SizedBox(height: 4),
                        _buildSidebarItem(
                          index: 1,
                          icon: Icons.grid_view_outlined,
                          selectedIcon: Icons.grid_view_rounded,
                          label: 'Catálogo de Belleza',
                          badgeText: '${_repo.totalProductsCount}',
                        ),
                        const SizedBox(height: 4),
                        _buildSidebarItem(
                          index: 2,
                          icon: Icons.shopping_bag_outlined,
                          selectedIcon: Icons.shopping_bag_rounded,
                          label: 'Bolsa de Compras',
                          badgeText: _cart.itemCount > 0
                              ? '${_cart.itemCount}'
                              : null,
                          highlightBadge: true,
                        ),
                        const SizedBox(height: 4),
                        _buildSidebarItem(
                          index: 3,
                          icon: Icons.admin_panel_settings_outlined,
                          selectedIcon: Icons.admin_panel_settings_rounded,
                          label: 'Admin, Perfil y API',
                        ),

                        const Spacer(),
                        const SizedBox(height: 16),

                        // Active User Footer + Logout
                        if (user != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            user.email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 34,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _auth.logout(),
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      size: 15,
                                    ),
                                    label: const Text(
                                      'Cerrar Sesión',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.dangerColor,
                                      side: BorderSide(
                                        color: AppTheme.dangerColor.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? badgeText,
    bool highlightBadge = false,
  }) {
    final isSelected = _currentIndex == index;
    return Material(
      color: isSelected
          ? AppTheme.primaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 21,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13.5,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: highlightBadge
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: highlightBadge
                          ? Colors.white
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartBadgeIcon({required bool isSelected}) {
    final count = _cart.itemCount;
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppTheme.primaryColor,
      label: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Icon(
        isSelected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
        color: isSelected ? AppTheme.primaryColor : null,
      ),
    );
  }
}
