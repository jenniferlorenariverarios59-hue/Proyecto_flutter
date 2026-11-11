import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tarjetas de métricas rápidas (Bento Cards) para la tienda Glam Studio.
class QuickMetricsBento extends StatelessWidget {
  final int totalCount;
  final double totalValue;
  final int restockCount;

  const QuickMetricsBento({
    super.key,
    required this.totalCount,
    required this.totalValue,
    required this.restockCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final cards = [
          _buildBentoItem(
            label: 'FÓRMULAS',
            value: '$totalCount',
            subtitle: '6 categorías',
            icon: Icons.auto_awesome_outlined,
            iconBg: AppTheme.primaryFixed,
            iconColor: AppTheme.primaryContainer,
            subColor: AppTheme.secondary,
            subIcon: Icons.verified_outlined,
            expandWidth: isWide,
          ),
          _buildBentoItem(
            label: 'VALOR BOUTIQUE',
            value: '\$${_formatCurrency(totalValue)}',
            subtitle: 'Inventario activo',
            icon: Icons.workspace_premium_outlined,
            iconBg: AppTheme.secondaryContainer,
            iconColor: AppTheme.onSecondaryContainer,
            subColor: AppTheme.onSurfaceVariant,
            subIcon: Icons.inventory_2_outlined,
            expandWidth: isWide,
          ),
          _buildBentoItem(
            label: 'POR REPONER',
            value: '$restockCount',
            subtitle: 'Stock bajo (≤10)',
            icon: Icons.notifications_active_outlined,
            iconBg: AppTheme.tertiaryContainer,
            iconColor: AppTheme.onTertiaryContainer,
            subColor: AppTheme.tertiary,
            subIcon: Icons.info_outline_rounded,
            expandWidth: isWide,
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              cards[0],
              const SizedBox(width: 12),
              cards[1],
              const SizedBox(width: 12),
              cards[2],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBentoItem({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color subColor,
    required IconData subIcon,
    bool expandWidth = false,
  }) {
    return Container(
      width: expandWidth ? null : 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(subIcon, size: 12, color: subColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
