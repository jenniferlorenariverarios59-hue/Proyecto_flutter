import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra horizontal de chips de filtrado para las 6 categorías de maquillaje y estado de stock.
class FilterChipsBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final String selectedStatus;
  final Function(String category) onCategorySelected;
  final Function(String status) onStatusSelected;

  const FilterChipsBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.onCategorySelected,
    required this.onStatusSelected,
  });

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Todos':
        return Icons.grid_view_rounded;
      case 'Labiales':
        return Icons.favorite_rounded;
      case 'Bases y correctores':
        return Icons.face_retouching_natural_rounded;
      case 'Sombras':
        return Icons.palette_rounded;
      case 'Máscaras de pestañas':
        return Icons.remove_red_eye_rounded;
      case 'Productos para el cuidado facial':
        return Icons.spa_rounded;
      case 'Accesorios de belleza':
        return Icons.brush_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Filtro de las 6 Categorías de Belleza
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onCategorySelected(cat),
                    borderRadius: BorderRadius.circular(9999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryContainer
                            : AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryContainer
                              : AppTheme.outlineVariant,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryContainer
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconForCategory(cat),
                            size: 15,
                            color: isSelected
                                ? AppTheme.softGold
                                : AppTheme.primaryContainer,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        // Fila 2: Filtro rápido de Disponibilidad
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStatusPill(
                id: 'all',
                label: 'Todo el catálogo',
                color: AppTheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              _buildStatusPill(
                id: 'in-stock',
                label: 'Disponibles (>10)',
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 8),
              _buildStatusPill(
                id: 'low-stock',
                label: 'Últimas unidades (≤10)',
                color: AppTheme.tertiary,
              ),
              const SizedBox(width: 8),
              _buildStatusPill(
                id: 'out-of-stock',
                label: 'Agotados',
                color: AppTheme.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required String id,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedStatus == id;
    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.12)
          : AppTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
        side: BorderSide(
          color: isSelected ? color : AppTheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onStatusSelected(id),
        borderRadius: BorderRadius.circular(9999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
