import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_app/models/item_transform.dart';
import 'package:outfit_app/widgets/outfit_layout_preview.dart';

void main() {
  group('ItemTransform', () {
    test('copyWith substitui apenas os campos informados', () {
      const t = ItemTransform(centerX: 0.5, centerY: 0.5, size: 0.3, z: 1);
      final r = t.copyWith(size: 0.6);
      expect(r.centerX, 0.5);
      expect(r.centerY, 0.5);
      expect(r.size, 0.6);
      expect(r.z, 1);
    });

    test('copyWith sem argumentos preserva o objeto', () {
      const t = ItemTransform(centerX: 0.2, centerY: 0.7, size: 0.4, z: 3);
      final r = t.copyWith();
      expect(r.centerX, t.centerX);
      expect(r.centerY, t.centerY);
      expect(r.size, t.size);
      expect(r.z, t.z);
    });
  });

  group('defaultTransformFor', () {
    test('retorna o layout anatômico por categoria conhecida', () {
      expect(defaultTransformFor('camisa'), kDefaultLayout['camisa']);
      expect(defaultTransformFor('sapato'), kDefaultLayout['sapato']);
    });

    test('categoria desconhecida cai no centro do canvas', () {
      final t = defaultTransformFor('inexistente');
      expect(t.centerX, 0.5);
      expect(t.centerY, 0.5);
      expect(t.size, 0.35);
    });
  });

  group('fitOutfitCanvas (posicionamento normalizado)', () {
    test('caixa mais larga que a proporção é limitada pela altura', () {
      final canvas = fitOutfitCanvas(const Size(200, 100));
      expect(canvas.height, 100);
      expect(canvas.width, closeTo(100 * kOutfitCanvasAspect, 1e-9));
    });

    test('caixa mais estreita que a proporção é limitada pela largura', () {
      final canvas = fitOutfitCanvas(const Size(50, 300));
      expect(canvas.width, 50);
      expect(canvas.height, closeTo(50 / kOutfitCanvasAspect, 1e-9));
    });

    test('canvas resultante sempre respeita a proporção fixa', () {
      for (final box in const [Size(300, 100), Size(100, 400), Size(120, 200)]) {
        final canvas = fitOutfitCanvas(box);
        expect(canvas.width / canvas.height,
            closeTo(kOutfitCanvasAspect, 1e-9));
      }
    });
  });
}
