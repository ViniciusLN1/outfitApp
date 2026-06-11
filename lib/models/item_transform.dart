/// Transformação normalizada (0..1) de uma peça dentro do canvas de um look.
/// As coordenadas são independentes de pixels: [centerX]/[centerY] são frações
/// da largura/altura do canvas e [size] é o lado (quadrado) como fração da
/// largura do canvas. Assim o mesmo arranjo é fiel em qualquer tamanho de tela.
class ItemTransform {
  final double centerX;
  final double centerY;
  final double size;
  final int z;

  const ItemTransform({
    required this.centerX,
    required this.centerY,
    required this.size,
    this.z = 0,
  });

  ItemTransform copyWith({
    double? centerX,
    double? centerY,
    double? size,
    int? z,
  }) =>
      ItemTransform(
        centerX: centerX ?? this.centerX,
        centerY: centerY ?? this.centerY,
        size: size ?? this.size,
        z: z ?? this.z,
      );
}

/// Proporção (largura / altura) fixa do canvas de montagem de looks.
/// Usada tanto no editor quanto na exibição para manter o arranjo idêntico.
const double kOutfitCanvasAspect = 0.66;

/// Layout padrão por categoria, imitando a anatomia (topo → base).
/// Aplicado quando o usuário salva sem ajustar manualmente.
const Map<String, ItemTransform> kDefaultLayout = {
  'chapeu': ItemTransform(centerX: 0.50, centerY: 0.08, size: 0.24, z: 0),
  'acessorios': ItemTransform(centerX: 0.17, centerY: 0.36, size: 0.18, z: 1),
  'camisa': ItemTransform(centerX: 0.50, centerY: 0.33, size: 0.42, z: 2),
  'blusa': ItemTransform(centerX: 0.82, centerY: 0.34, size: 0.26, z: 3),
  'cinto': ItemTransform(centerX: 0.50, centerY: 0.55, size: 0.34, z: 4),
  'calca': ItemTransform(centerX: 0.50, centerY: 0.73, size: 0.40, z: 5),
  'sapato': ItemTransform(centerX: 0.50, centerY: 0.92, size: 0.26, z: 6),
};

ItemTransform defaultTransformFor(String category) =>
    kDefaultLayout[category] ??
    const ItemTransform(centerX: 0.5, centerY: 0.5, size: 0.35);
