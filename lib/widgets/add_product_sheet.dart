import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Formulario interactivo para registrar un nuevo producto de maquillaje y belleza.
/// Incluye validación completa, selector de las 6 categorías oficiales, marca,
/// tono principal con paleta de color rápida, controles de stock (+/-), imagen y descripción.
class AddProductSheet extends StatefulWidget {
  final Future<void> Function(Product product) onSave;

  const AddProductSheet({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(Product product) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddProductSheet(onSave: onSave),
    );
  }

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController(text: 'Glam Studio Paris');
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '20');
  final _shadeNameController = TextEditingController(text: 'Rosa Empolvado');
  final _finishController = TextEditingController(text: 'Acabado Terciopelo');
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = Product.officialCategories.first;
  String _selectedShadeHex = '#C86D7A';
  bool _isSaving = false;

  static const List<Map<String, String>> _shadePalette = [
    {'name': 'Rosa Empolvado', 'hex': '#C86D7A'},
    {'name': 'Vino Imperial', 'hex': '#6B1D2F'},
    {'name': 'Rojo Rubí', 'hex': '#B81D24'},
    {'name': 'Nude Almendra', 'hex': '#D8A48F'},
    {'name': 'Beige Seda', 'hex': '#E5BFA6'},
    {'name': 'Dorado Champagne', 'hex': '#D4AF37'},
    {'name': 'Negro Obsidiana', 'hex': '#1C1619'},
  ];

  final Map<String, String> _defaultCategoryImages = {
    'Labiales':
        'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=700&auto=format&fit=crop&q=80',
    'Bases y correctores':
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=700&auto=format&fit=crop&q=80',
    'Sombras':
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=700&auto=format&fit=crop&q=80',
    'Máscaras de pestañas':
        'https://images.unsplash.com/photo-1631214540553-ff044a3ff1d4?w=700&auto=format&fit=crop&q=80',
    'Productos para el cuidado facial':
        'https://images.unsplash.com/photo-1608248597359-0e6d526a6828?w=700&auto=format&fit=crop&q=80',
    'Accesorios de belleza':
        'https://images.unsplash.com/photo-1526045612212-70caf35c14df?w=700&auto=format&fit=crop&q=80',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _shadeNameController.dispose();
    _finishController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockController.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 9999);
    setState(() {
      _stockController.text = next.toString();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim().isEmpty
        ? 'Glam Studio Paris'
        : _brandController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final shadeName = _shadeNameController.text.trim().isEmpty
        ? 'Rosa Empolvado'
        : _shadeNameController.text.trim();
    final finish = _finishController.text.trim().isEmpty
        ? 'Acabado Profesional'
        : _finishController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? 'Fórmula cosmética de alta pigmentación, dermatológicamente probada y libre de crueldad animal.'
        : _descController.text.trim();

    final inputImage = _imageUrlController.text.trim();
    final imageUrl = inputImage.isNotEmpty
        ? inputImage
        : (_defaultCategoryImages[_selectedCategory] ??
            _defaultCategoryImages['Labiales']);

    final prefix = _selectedCategory.substring(0, 3).toUpperCase();
    final randomSuffix =
        (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
    final sku = 'SKU-$prefix-$randomSuffix';

    final newProduct = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      brand: brand,
      description: desc,
      price: price,
      stock: stock,
      category: _selectedCategory,
      sku: sku,
      imageUrl: imageUrl,
      rating: 5.0,
      reviewsCount: 18,
      isFeatured: true,
      finish: finish,
      shadeName: shadeName,
      shadeHex: _selectedShadeHex,
      shades: [
        ProductShade(name: shadeName, hex: _selectedShadeHex),
        const ProductShade(name: 'Vino Imperial', hex: '#6B2737'),
      ],
    );

    try {
      await widget.onSave(newProduct);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: keyboardPadding + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryFixed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.primaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMINISTRACIÓN DE CATÁLOGO',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryContainer,
                            letterSpacing: 0.9,
                          ),
                        ),
                        Text(
                          'Registrar Nuevo Cosmético',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Nombre y Marca
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto *',
                        hintText: 'Ej. Labial Velvet Rosé',
                        prefixIcon: Icon(Icons.spa_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'El nombre es obligatorio.';
                        }
                        if (val.trim().length < 3) {
                          return 'Mínimo 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca *',
                        prefixIcon: Icon(Icons.verified_outlined, size: 19),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Categoría por Chips (Las 6 categorías oficiales)
              const Text(
                'Categoría de Belleza *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: Product.officialCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        selectedColor: AppTheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        backgroundColor: AppTheme.surfaceContainerLow,
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Precio y Stock
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio (USD) *',
                        hintText: 'Ej. 24.50',
                        prefixIcon: Icon(Icons.attach_money, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingrese el precio.';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num <= 0) {
                          return 'Mayor a 0.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => _adjustStock(-1),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              validator: (val) {
                                final n = int.tryParse(val?.trim() ?? '');
                                if (n == null || n < 0) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => _adjustStock(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Tono cosmético y Acabado
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shadeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Tono',
                        prefixIcon: Icon(Icons.palette_outlined, size: 19),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _finishController,
                      decoration: const InputDecoration(
                        labelText: 'Textura / Acabado',
                        prefixIcon: Icon(Icons.flare_rounded, size: 19),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _shadePalette.map((item) {
                    final hex = item['hex']!;
                    final name = item['name']!;
                    final color = ProductShade(name: name, hex: hex).color;
                    final isSel = _selectedShadeHex == hex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedShadeHex = hex;
                          _shadeNameController.text = name;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppTheme.primaryFixed
                              : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? AppTheme.primaryContainer
                                : AppTheme.outlineVariant,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // 5. URL de imagen y Descripción
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Fotografía (opcional, usa imagen por categoría si se omite)',
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción y Beneficios Cosméticos',
                  hintText: 'Fórmula de larga duración enriquecida con vitamina E...',
                  prefixIcon: Icon(Icons.description_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    _isSaving ? 'Guardando...' : 'Publicar en el Catálogo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
