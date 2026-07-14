import 'package:flutter/material.dart';

/// Cartão padrão do design system. [plate] = true usa o fundo greige
/// ("prancha" de lookbook, para abrigar fotos de peças); false usa a
/// superfície branca padrão.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool plate;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.plate = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Padding(padding: padding, child: child);
    return Material(
      color: plate ? scheme.surfaceContainerHighest : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: onTap != null ? InkWell(onTap: onTap, child: body) : body,
    );
  }
}
