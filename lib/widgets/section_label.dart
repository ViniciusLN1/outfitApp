import 'package:flutter/material.dart';

/// Rótulo editorial de seção (eyebrow). Movido de stats para uso global.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 22, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
