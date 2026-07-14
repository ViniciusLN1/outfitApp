import 'package:flutter/material.dart';

import 'app_card.dart';

/// KPI unificado: número grande em didone + rótulo. Substitui os cartões de
/// métrica divergentes de Perfil, Estatísticas e Home.
class KpiTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const KpiTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // FittedBox: encolhe o conteúdo em vez de estourar quando o tile recebe
    // menos altura que o intrínseco (ex.: grids com aspect ratio fixo).
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
        ),
      ),
    );
  }
}
