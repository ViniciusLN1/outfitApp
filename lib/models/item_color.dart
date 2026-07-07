import 'package:flutter/material.dart';

/// Paleta fixa de cores das peças. O valor persistido é a chave (minúscula);
/// o swatch é derivado deste mapa para exibição consistente.
const Map<String, Color> kItemColors = {
  'preto': Color(0xFF000000),
  'branco': Color(0xFFFFFFFF),
  'cinza': Color(0xFF9E9E9E),
  'azul': Color(0xFF1565C0),
  'vermelho': Color(0xFFD32F2F),
  'verde': Color(0xFF2E7D32),
  'amarelo': Color(0xFFFBC02D),
  'marrom': Color(0xFF6D4C41),
  'rosa': Color(0xFFEC407A),
  'laranja': Color(0xFFF57C00),
  'roxo': Color(0xFF7B1FA2),
  'bege': Color(0xFFD7CCA3),
};

/// Rótulo legível de uma cor (primeira letra maiúscula).
String colorLabel(String key) =>
    key.isEmpty ? '' : key[0].toUpperCase() + key.substring(1);

/// Swatch de exibição; cinza neutro para cores desconhecidas.
Color colorSwatch(String? key) => kItemColors[key] ?? const Color(0xFFBDBDBD);

/// Círculo de cor com borda fina — usado em dropdowns e legendas de cor.
class ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  const ColorDot({super.key, required this.color, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
