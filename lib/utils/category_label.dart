import '../controllers/constructor_controller.dart';

/// Rótulo humano para o nome cru da categoria persistido no banco.
String catLabel(String name) {
  final match = ClothingCategory.values.where((c) => c.name == name);
  return match.isEmpty ? name : match.first.displayName;
}
