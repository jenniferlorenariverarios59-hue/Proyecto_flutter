import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/add_product_sheet.dart';
import '../widgets/edit_product_sheet.dart';
import 'product_detail_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProductRepository _repo = ProductRepository();
  final AuthService _auth = AuthService();
  final TextEditingController _urlCtrl = TextEditingController();
  final TextEditingController _adminSearchCtrl = TextEditingController();

  bool _isTesting = false;
  bool? _testResult;
  String _selectedAdminCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _urlCtrl.text = ApiService.baseUrl;
    _repo.addListener(_onStateChanged);
    _auth.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onStateChanged);
    _auth.removeListener(_onStateChanged);
    _urlCtrl.dispose();
    _adminSearchCtrl.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _testAndSaveUrl() async {
    final newUrl = _urlCtrl.text.trim();
    if (newUrl.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    ApiService.baseUrl = newUrl;
    final res = await ApiService().testConnection(newUrl);
    final success = res['success'] == true;

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = success;
      });

      if (success) {
        _repo.setOfflineMode(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Conexión exitosa con la API REST! Catálogo sincronizado.',
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se detectó servidor activo en esa URL. Operando con persistencia local.',
            ),
            backgroundColor: AppTheme.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final user = _auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final cityCtrl = TextEditingController(text: user.city);
    String skinType = user.skinType.isNotEmpty ? user.skinType : 'Mixta';
    final skinTypes = ['Normal', 'Mixta', 'Grasa', 'Seca', 'Sensible'];
    if (!skinTypes.contains(skinType)) {
      skinType = 'Mixta';
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Editar Perfil de Usuario',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().length < 3
                          ? 'Ingresa un nombre válido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad de envío',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: skinType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de piel',
                        prefixIcon: Icon(Icons.face_retouching_natural_rounded),
                      ),
                      items: skinTypes
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text('Piel $s'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => skinType = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await _auth.updateProfile(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  skinType: skinType,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente'),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar producto?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.name}" del catálogo? Esta acción actualizará la base de datos y la API REST.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${product.name}" eliminado del catálogo'),
                    backgroundColor: AppTheme.dangerColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Product> get _filteredAdminProducts {
    final query = _adminSearchCtrl.text.trim().toLowerCase();
    return _repo.products.where((p) {
      final matchesCat =
          _selectedAdminCategory == 'Todas' ||
          p.category == _selectedAdminCategory;
      final matchesSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query);
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final adminProducts = _filteredAdminProducts;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administración, Perfil y API',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Gestiona tu cuenta, el inventario de maquillaje y la conexión con el servidor REST',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => AddProductSheet.show(
                          context,
                          onSave: (prod) async {
                            await _repo.addProduct(prod);
                          },
                        ),
                        icon: const Icon(Icons.add_rounded, size: 19),
                        label: const Text('Nuevo Producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 1. User Profile Card (Login/Logout/Edit)
                  if (user != null) _buildUserProfileCard(user),
                  const SizedBox(height: 24),

                  // 2. Inventory Administration Section (CRUD)
                  _buildSectionTitle(
                    icon: Icons.inventory_2_outlined,
                    title: 'Administración del Catálogo de Productos (CRUD)',
                    subtitle:
                        'Registra, edita, consulta o elimina productos de las 6 categorías oficiales',
                  ),
                  const SizedBox(height: 12),
                  _buildInventoryKpis(),
                  const SizedBox(height: 14),
                  _buildAdminCatalogManager(adminProducts),
                  const SizedBox(height: 28),

                  // 3. Backend & REST API Section
                  _buildSectionTitle(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Conexión Base de Datos & API REST',
                    subtitle:
                        'Configura el endpoint de Node.js / Express o trabaja con persistencia local',
                  ),
                  const SizedBox(height: 12),
                  _buildApiConfigurationCard(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A1525), Color(0xFF6B2737)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.accentGold,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D101E),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentGold),
                          ),
                          child: Text(
                            user.isAdmin ? 'ADMINISTRADORA' : 'CLIENTE VIP',
                            style: const TextStyle(
                              color: Color(0xFFF9E498),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Piel: ${user.skinType} • Ciudad: ${user.city.isEmpty ? "Colombia" : user.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Editar Perfil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _auth.logout();
                },
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryKpis() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final double tileWidth;
        if (maxW >= 960) {
          tileWidth = (maxW - 36) / 4;
        } else if (maxW >= 480) {
          tileWidth = (maxW - 12) / 2;
        } else {
          tileWidth = maxW;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiTile(
              width: tileWidth,
              icon: Icons.spa_outlined,
              label: 'Productos en Catálogo',
              value: '${_repo.totalProductsCount}',
              color: AppTheme.primaryColor,
            ),
            _buildKpiTile(
              width: tileWidth,
              icon: Icons.inventory_rounded,
              label: 'Unidades en Stock',
              value: '${_repo.totalStockCount}',
              color: AppTheme.secondaryColor,
            ),
            _buildKpiTile(
              width: tileWidth,
              icon: Icons.payments_outlined,
              label: 'Valor del Inventario',
              value: _repo.formattedTotalInventoryValue,
              color: AppTheme.successColor,
            ),
            _buildKpiTile(
              width: tileWidth,
              icon: Icons.warning_amber_rounded,
              label: 'Stock Bajo / Agotado',
              value: '${_repo.lowStockCount + _repo.outOfStockCount}',
              color: AppTheme.warningColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiTile({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCatalogManager(List<Product> products) {
    final categories = ['Todas', ...Product.officialCategories];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top toolbar: Search + Category Filter + Restore button
          LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final isNarrow = maxW < 620;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isNarrow ? maxW : 290,
                    child: TextField(
                      controller: _adminSearchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Buscar por nombre, marca o SKU...',
                        hintStyle: const TextStyle(fontSize: 12.5),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        suffixIcon: _adminSearchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () {
                                  _adminSearchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow ? maxW : 240,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedAdminCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedAdminCategory = v);
                        }
                      },
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _repo.fetchProductsFromApi(),
                    icon: const Icon(Icons.sync_rounded, size: 17),
                    label: const Text('Sincronizar API'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await _repo.resetToInitialCatalog();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Catálogo oficial de belleza restaurado correctamente',
                            ),
                            backgroundColor: AppTheme.successColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restore_rounded, size: 17),
                    label: const Text('Restaurar Catálogo Base'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay productos que coincidan con el filtro seleccionado.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 14),
              itemBuilder: (context, index) {
                final p = products[index];
                return LayoutBuilder(
                  builder: (context, itemConstraints) {
                    final isCompactRow = itemConstraints.maxWidth < 460;
                    return Row(
                      children: [
                        // Image
                        GestureDetector(
                          onTap: () => ProductDetailSheet.show(context, p),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 52,
                              height: 52,
                              color: const Color(0xFFF9F1F3),
                              child: p.imageUrl != null &&
                                      p.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      p.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.spa_rounded,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.spa_rounded,
                                      color: AppTheme.secondaryColor,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${p.brand} • ${p.category} • ${p.formattedPrice}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (isCompactRow) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.stock > 5
                                        ? AppTheme.successColor.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppTheme.warningColor.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Stock: ${p.stock}',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.stock > 5
                                          ? AppTheme.successColor
                                          : AppTheme.warningColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Stock quick adjust on wider screens
                        if (!isCompactRow) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.stock > 5
                                  ? AppTheme.successColor.withValues(alpha: 0.1)
                                  : AppTheme.warningColor.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Stock: ${p.stock}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: p.stock > 5
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Actions: Edit & Delete
                        IconButton(
                          visualDensity: isCompactRow
                              ? VisualDensity.compact
                              : VisualDensity.standard,
                          onPressed: () => EditProductSheet.show(
                            context,
                            product: p,
                            onSave: (updated) async {
                              await _repo.updateProduct(updated);
                            },
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          tooltip: 'Editar producto',
                        ),
                        IconButton(
                          visualDensity: isCompactRow
                              ? VisualDensity.compact
                              : VisualDensity.standard,
                          onPressed: () => _confirmDeleteProduct(p),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.dangerColor,
                            size: 20,
                          ),
                          tooltip: 'Eliminar producto',
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildApiConfigurationCard() {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  'Modo Persistente Local (SharedPreferences)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text(
                  'Guarda todos los cambios de productos, usuarios y carrito en el dispositivo cuando el servidor Node.js no está encendido.',
                  style: TextStyle(fontSize: 12.5),
                ),
                value: _repo.offlineMode,
                activeThumbColor: AppTheme.primaryColor,
                onChanged: (val) => _repo.setOfflineMode(val),
              ),
            ),
            const Divider(height: 24),
            const Text(
              'URL del Servidor REST (Node.js / Express)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 6),
            const Text(
              '• Navegador Web / Windows: http://localhost:3000/api\n• Emulador Android Studio: http://10.0.2.2:3000/api',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text(
                    'Web / Localhost (localhost:3000)',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  onPressed: () {
                    _urlCtrl.text = 'http://localhost:3000/api';
                  },
                ),
                ActionChip(
                  label: const Text(
                    'Emulador Android (10.0.2.2:3000)',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  onPressed: () {
                    _urlCtrl.text = 'http://10.0.2.2:3000/api';
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 480;
                final urlField = TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText: 'http://localhost:3000/api',
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: _testResult == null
                        ? null
                        : Icon(
                            _testResult!
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: _testResult!
                                ? AppTheme.successColor
                                : AppTheme.dangerColor,
                          ),
                  ),
                );
                final connectBtn = SizedBox(
                  height: 48,
                  width: isNarrow ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testAndSaveUrl,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: const Text('Conectar API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      urlField,
                      const SizedBox(height: 10),
                      connectBtn,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: urlField),
                    const SizedBox(width: 12),
                    connectBtn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
